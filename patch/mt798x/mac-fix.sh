#!/bin/bash

MODEL="ruijie,rg-x60-new"

TREE=""
P="$PWD"
for _ in 1 2 3 4 5 6; do
    if [ -d "$P/target/linux/mediatek" ]; then
        TREE="$P"
        break
    fi
    P="$(cd "$P/.." && pwd)"
done

if [ -z "$TREE" ]; then
    echo "::warning::MAC 修复：没找到 target/linux/mediatek，跳过"
    exit 0
fi

echo ">> 检查 $TREE 的网络默认 MAC（$MODEL）"

FILES=$(grep -rl --include=02_network -F "mediatek_setup_macs" "$TREE/target/linux/mediatek" 2>/dev/null)
if [ -z "$FILES" ]; then
    echo "::warning::MAC 修复：没找到包含 mediatek_setup_macs 的 02_network，跳过"
    exit 0
fi

echo "$FILES" | while IFS= read -r f; do
    [ -n "$f" ] || continue

    if grep -qF "${MODEL}*)" "$f"; then
        echo "  已经改过，跳过 $f"
        continue
    fi

    fs=$(grep -n -F "mediatek_setup_macs()" "$f" | head -n 1 | cut -d: -f1)
    if [ -z "$fs" ]; then
        echo "::warning::$f 里没找到 mediatek_setup_macs 函数，跳过"
        continue
    fi

    cl=$(awk -v s="$fs" 'NR >= s && /case .*\$board.* in/ {print NR; exit}' "$f")
    if [ -z "$cl" ]; then
        echo "::warning::$f 里没找到 case \$board in，跳过"
        continue
    fi

    awk -v at="$cl" -v p="${MODEL}*)" '
        NR == at {
            print
            print "\t" p
            print "\t\tlabel_mac=$(mtd_get_mac_ascii product_info ethaddr)"
            print "\t\t[ -n \"$label_mac\" ] || label_mac=$(mtd_get_mac_ascii u-boot-env ethaddr)"
            print "\t\t[ -n \"$label_mac\" ] || label_mac=$(mtd_get_mac_ascii factory ethaddr)"
            print "\t\t[ -n \"$label_mac\" ] || label_mac=$(mtd_get_mac_ascii Factory ethaddr)"
            print "\t\tcase \"$label_mac\" in"
            print "\t\t[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:*) ;;"
            print "\t\t*) label_mac=\"\" ;;"
            print "\t\tesac"
            print "\t\tif [ -n \"$label_mac\" ]; then"
            print "\t\t\twan_mac=$label_mac"
            print "\t\t\tlan_mac=$(macaddr_add \"$label_mac\" 1)"
            print "\t\tfi"
            print "\t\t;;"
            next
        }
        { print }
    ' "$f" > "$f.new" && mv "$f.new" "$f"

    echo "  已改 $f"
done

UCI_DEF="$TREE/package/base-files/files/etc/uci-defaults/99-fix-ruijie-mac"
mkdir -p "$(dirname "$UCI_DEF")"
cat > "$UCI_DEF" <<'EOU'
#!/bin/sh

. /lib/functions.sh
. /lib/functions/system.sh

base=$(mtd_get_mac_ascii u-boot-env ethaddr)
[ -n "$base" ] || exit 0

case "$base" in
	[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:*) ;;
	*) exit 0 ;;
esac

lan=$(macaddr_add "$base" 1 2>/dev/null)
if [ -z "$lan" ]; then
	lan=$(printf '%s\n' "$base" | awk -F: '{n=("0x" $6)+1; if (n>255) n=0; printf "%s:%s:%s:%s:%s:%02x\n", $1, $2, $3, $4, $5, n}')
fi
[ -n "$lan" ] || exit 0

uci -q set network.wan.macaddr="$base"
uci -q set network.lan.macaddr="$lan"
for s in $(uci -q show network | sed -n "s/^network\.\(@device\[[0-9]*\]\)\.name='br-lan'$/\1/p"); do
	uci -q set network.$s.macaddr="$lan"
done
uci -q commit network
exit 0
EOU
chmod +x "$UCI_DEF"
echo "  已写入首启脚本 $UCI_DEF"

exit 0
