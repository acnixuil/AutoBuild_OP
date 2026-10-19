#!/bin/bash

declare -a RESULTS=()          # 收集结果用于 summary
FAILED=0
ARCH="${ARCH:-unknown}"        # 防空
PKG_PATCH="$GITHUB_WORKSPACE/openwrt/package"
PATCH_DIR="$GITHUB_WORKSPACE/patch"

# ---- 调度器：处理日志、状态、可选/必需 ----
# run_step <名称> <条件检查函数> <执行函数> [required]
run_step() {
  local name="$1" check="$2" exec="$3" required="${4:-optional}"
  echo -e "\n\033[0;32m==== ${name} ====\033[0m"

  cd "$PKG_PATCH" || exit 1

  if ! "$check"; then
    echo "  ⏭  跳过（条件不满足）"
    RESULTS+=("| ${name} | SKIP | - |")
    return 0
  fi

  local t0=$SECONDS
  if "$exec"; then
    local dt=$((SECONDS - t0))
    echo "  ✅ 完成（${dt}s）"
    RESULTS+=("| ${name} | OK | ${dt}s |")
  else
    local dt=$((SECONDS - t0))
    echo "  ❌ 失败（${dt}s）"
    RESULTS+=("| ${name} | **FAIL** | ${dt}s |")
    if [ "$required" = "required" ]; then
      echo "  ⛔ 必需步骤失败，终止"
      summary 
      exit 1 
    fi
    FAILED=$((FAILED + 1))
  fi
}

# ---- 公共辅助函数（供业务函数调用） ----
UI_URL="https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages-misans-only.zip"
GEO_IP="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
GEO_SITE="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
GEO_MMDB="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb"

download_ui() {
  local target_dir="$1"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  if curl -sL "$UI_URL" -o "$tmp_dir/ui.zip" && unzip -q "$tmp_dir/ui.zip" -d "$tmp_dir"; then
    rm -rf "$target_dir"/*
    mkdir -p "$target_dir"
    cp -r "$tmp_dir"/*/* "$target_dir"/
    rm -rf "$tmp_dir"
    return 0
  fi
  rm -rf "$tmp_dir"
  return 1
}

check_openclash() { [ -d "./luci-app-openclash" ]; }
handle_openclash() {
  local alpha_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha"
  local core_meta
  core_meta=$(curl -sL "$alpha_api" | grep "browser_download_url" | grep -oE "https://[^\"]*mihomo-linux-${ARCH}-alpha-[0-9a-z]+\.gz" | head -n 1)

  [ -n "$core_meta" ] || return 1

  download_ui "./luci-app-openclash/root/usr/share/openclash/ui/zashboard" || return 1

  cd ./luci-app-openclash/root/etc/openclash/ || return 1
  rm -f GeoSite.dat Country.mmdb

  local tmp_dir
  tmp_dir=$(mktemp -d)
  if curl -sL "$core_meta" | gzip -dc > "$tmp_dir/clash_meta"; then
    [ -s "$tmp_dir/clash_meta" ] || { rm -rf "$tmp_dir"; return 1; }
    mkdir -p ./core
    mv -f "$tmp_dir/clash_meta" "./core/clash_meta"
    chmod +x "./core/clash_meta"
  else
    rm -rf "$tmp_dir"
    return 1
  fi
  rm -rf "$tmp_dir"
  return 0
}

check_nikki() { [ -d "./nikki" ]; }
handle_nikki() {
  download_ui "./nikki/luci-app-nikki/root/etc/nikki/run/ui" || return 1
  cd ./nikki/luci-app-nikki/root/etc/nikki/run || return 1
  if [[ "$REPO_URL" != *"VIKINGYFY"* && "$REPO_URL" != *"LiBwrt"* && "$REPO_URL" != *"mt798x"* ]]; then
    curl -sL -o ASN.mmdb "$GEO_MMDB"
    curl -sL -o GeoSite.dat "$GEO_SITE"
    curl -sL -o GeoIP.dat "$GEO_IP"
  fi
  return 0
}

check_momo() { [ -d "./momo" ]; }
handle_momo() {
  mkdir -p ./momo/luci-app-momo/root/etc/momo/run
  download_ui "./momo/luci-app-momo/root/etc/momo/run/ui" || return 1
  return 0
}

check_adguard() { [ -d "./luci-app-adguardhome" ]; }
handle_adguard() {
  local agh_dir="luci-app-adguardhome/root/usr/bin"
  mkdir -p "./$agh_dir"
  local agh_core
  agh_core=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep "browser_download_url" | grep -oE "https://[^\"]*AdGuardHome_linux_${ARCH}\.tar\.gz" | head -n 1)
  [ -n "$agh_core" ] || return 1

  local tmp_dir
  tmp_dir=$(mktemp -d)
  if curl -sL "$agh_core" | tar -xzf - -C "$tmp_dir"; then
    local agh_bin
    agh_bin=$(find "$tmp_dir" -type f -name "AdGuardHome" | head -n 1)
    [ -n "$agh_bin" ] && [ -f "$agh_bin" ] || { rm -rf "$tmp_dir"; return 1; }
    mv -f "$agh_bin" "./$agh_dir/AdGuardHome"
    chmod +x "./$agh_dir/AdGuardHome"
  else
    rm -rf "$tmp_dir"
    return 1
  fi
  rm -rf "$tmp_dir"
  return 0
}

check_singbox() { [ "$ARCH" = "arm64" ] || [ "$ARCH" = "amd64" ]; }
handle_singbox() {
  [ -f "$PATCH_DIR/sing-box/Makefile" ] || return 1
  rm -rf ../feeds/packages/net/sing-box
  mkdir -p ./sing-box

  local SINGBOX_URL="https://singbox-custom-dl.pages.dev/sing-box-reF1nd-stable-${ARCH}.tar.gz"

  cp -f "$PATCH_DIR/sing-box/Makefile" ./sing-box/Makefile
  return 0
}

check_tailscale() { [ -f "../feeds/packages/net/tailscale/Makefile" ]; }
handle_tailscale() {
  local ts_makefile="../feeds/packages/net/tailscale/Makefile"
  [ -f "$PATCH_DIR/tailscale/Makefile" ] || return 1

  local ts_version
  ts_version=$(curl -sL https://api.github.com/repos/acnixuil/glinet-tailscale-updater/releases/latest | grep '"tag_name":' | head -n 1 | awk -F '"' '{print $4}' || true)
  
  [ -n "$ts_version" ] || return 1

  local clean_version="${ts_version#v}"
  local ts_url="https://github.com/acnixuil/glinet-tailscale-updater/releases/download/${ts_version}/tailscaled-linux-${ARCH}"

  cp -f "$PATCH_DIR/tailscale/Makefile" "$ts_makefile"

  sed -i "s/__VERSION__/${clean_version}/g" "$ts_makefile"
  sed -i "s#__URL__#${ts_url}#g" "$ts_makefile"  # 链接包含斜杠，sed 分隔符改用 #

  return 0
}

check_argon() { [ -d "./luci-theme-argon" ]; }
handle_argon() {
  cp -f "$GITHUB_WORKSPACE/images/bg1.jpg" "luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg" 2>/dev/null || true
  local css_files
  css_files=$(find luci-theme-argon -type f -iname "*.css")
  [ -n "$css_files" ] && sed -i "/font-weight:/ { /important/! { /\/\*/! s/:.*/: var(--font-weight);/ } }" $css_files
  if [ -f "luci-app-argon-config/root/etc/config/argon" ]; then
    sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'600'/'normal'/" "luci-app-argon-config/root/etc/config/argon"
  fi
  return 0
}

handle_syspatch() {
  cd "$GITHUB_WORKSPACE/openwrt/" || return 1
  local zt_menu="feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json"
  local upnp_po="feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po"

  [ -f "$zt_menu" ] && sed -i 's/vpn/services/g' "$zt_menu"
  [ -f "$upnp_po" ] && sed -i 's/msgstr "UPnP IGD 和 PCP\/NAT-PMP"/msgstr "UPnP"/' "$upnp_po"
  return 0
}

summary() {
  [ -n "$GITHUB_STEP_SUMMARY" ] || return 0
  {
    echo "### Handles.sh 处理结果"
    echo "| 步骤 | 状态 | 耗时 |"
    echo "|---|---|---|"
    printf '%s\n' "${RESULTS[@]}"
    [ "$FAILED" -gt 0 ] && echo -e "\n> ⚠️ ${FAILED} 个可选步骤失败，请查看上方日志"
  } >> "$GITHUB_STEP_SUMMARY"
  return 0
}

cd "$PKG_PATCH" || exit 1
run_step "OpenClash"    check_openclash    handle_openclash    optional
run_step "Nikki"        check_nikki        handle_nikki        optional
run_step "Momo"         check_momo         handle_momo         optional
run_step "AdGuardHome"  check_adguard      handle_adguard      optional
run_step "sing-box"     check_singbox      handle_singbox      optional
run_step "Tailscale"    check_tailscale    handle_tailscale    required
run_step "Argon 样式"   check_argon        handle_argon        optional
run_step "系统修补"     true               handle_syspatch     required

summary
[ "$FAILED" -gt 0 ] && echo "> 有可选步骤失败，但不阻断编译" 
exit 0