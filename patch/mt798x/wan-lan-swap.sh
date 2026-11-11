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
    echo "::warning::WAN/LAN 对换：没找到 target/linux/mediatek，跳过"
    exit 0
fi

echo ">> 检查 $TREE 的默认网络映射（$MODEL）"

FILES=$(grep -rl --include=02_network -F "$MODEL" "$TREE/target/linux/mediatek" 2>/dev/null)
if [ -z "$FILES" ]; then
    echo "::warning::WAN/LAN 对换：没有包含 $MODEL 的 02_network，跳过"
    exit 0
fi

echo "$FILES" | while IFS= read -r f; do
    [ -n "$f" ] || continue

    if grep -qE "^[[:space:]]*${MODEL//,/\,}\*\)" "$f"; then
        echo "  已经改过，跳过 $f"
        continue
    fi

    pn=$(grep -nF "$MODEL" "$f" | head -n 1 | cut -d: -f1)
    ul=$(awk -v s="$pn" 'NR>=s && /ucidef_set_interfaces_lan_wan/ {print NR; exit}' "$f")
    if [ -z "$ul" ]; then
        echo "::warning::$f 里没找到 $MODEL 对应的 ucidef_set_interfaces_lan_wan，跳过"
        continue
    fi

    line=$(sed -n "${ul}p" "$f")
    lan=$(printf '%s' "$line" | sed -E 's/^[^"]*"([^"]*)".*$/\1/')
    wan=$(printf '%s' "$line" | sed -E 's/^[^"]*"[^"]*"[[:space:]]+([^[:space:]]+).*$/\1/')

    case " $lan " in
        *" eth1 "*) echo "  $f 的 LAN 里已经包含 eth1，跳过"; continue ;;
    esac
    if [ "$wan" != "eth1" ]; then
        echo "::warning::$f 的 WAN 不是 eth1（实际 $wan），跳过"
        continue
    fi

    if [ -n "${SWAP_WAN_PORT:-}" ]; then
        case " $lan " in
            *" $SWAP_WAN_PORT "*) ;;
            *) echo "::warning::SWAP_WAN_PORT=$SWAP_WAN_PORT 不在 $lan 里，跳过"; continue ;;
        esac
        first="$SWAP_WAN_PORT"
        rest=$(printf '%s\n' $lan | grep -vx "$first" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
    else
        first=${lan%% *}
        rest=${lan#* }
    fi

    if [ "$rest" = "$lan" ] || [ -z "$rest" ]; then
        echo "::warning::$f 的 LAN 只有 $lan 一个口，无法对换，跳过"
        continue
    fi

    cl=$(grep -nE '^[[:space:]]*case .* in[[:space:]]*$' "$f" | head -n 1 | cut -d: -f1)
    if [ -z "$cl" ]; then
        echo "::warning::$f 里没找到 case 分支起点，跳过"
        continue
    fi

    awk -v at="$cl" -v p="${MODEL}*)" -v l="$rest eth1" -v w="$first" '
        NR == at {
            print
            print "\t" p
            print "\t\tucidef_set_interfaces_lan_wan \"" l "\" \"" w "\""
            print "\t\t;;"
            next
        }
        { print }
    ' "$f" > "$f.new" && mv "$f.new" "$f"

    echo "  已改 $f"
    echo "    LAN: $rest eth1"
    echo "    WAN: $first"
done

exit 0
