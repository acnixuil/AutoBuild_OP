#!/bin/bash

declare -a RESULTS=()          # 收集结果用于 summary
FAILED=0
# 架构：环境变量优先；否则按 编译树 .config → 机型 config → 目标平台映射 → 宿主机 uname 的顺序判断
if [ -z "$ARCH" ]; then
  _cfg=""
  for _c in "$GITHUB_WORKSPACE/openwrt/.config" "${GITHUB_WORKSPACE:+$GITHUB_WORKSPACE/}${CONFIG_FILE:-}" "${CONFIG_FILE:-}"; do
    [ -n "$_c" ] && [ -f "$_c" ] && { _cfg="$_c"; break; }
  done
  _arch_raw=""
  _arch_src=""
  if [ -n "$_cfg" ]; then
    _arch_raw=$(sed -n 's/^CONFIG_ARCH="\([^"]*\)"/\1/p' "$_cfg" | head -n 1)
    [ -n "$_arch_raw" ] && _arch_src="$_cfg 的 CONFIG_ARCH"
  fi
  if [ -z "$_arch_raw" ] && [ -n "$_cfg" ]; then
    _board=$(sed -n 's/^CONFIG_TARGET_BOARD="\([^"]*\)"/\1/p' "$_cfg" | head -n 1)
    if [ -z "$_board" ]; then
      _board=$(sed -n 's/^CONFIG_TARGET_\([A-Za-z0-9]*\)=y$/\1/p' "$_cfg" | head -n 1)
    fi
    case "${_board%%_*}" in
      mediatek|qualcommax|rockchip) _arch_raw="aarch64" ;;
      x86) _arch_raw="x86_64" ;;
      *) _arch_raw="" ;;
    esac
    [ -n "$_arch_raw" ] && _arch_src="$_cfg 的目标平台 ${_board%%_*}"
  fi
  if [ -z "$_arch_raw" ]; then
    _arch_raw=$(uname -m)
    _arch_src="宿主机 uname -m"
    echo "::warning::没从配置里认出目标架构，退回避难宿主机 $_arch_raw"
  fi
  case "$_arch_raw" in
    aarch64|arm64) ARCH="arm64" ;;
    x86_64|amd64) ARCH="amd64" ;;
    armv7*|armv6*|arm) ARCH="armv7" ;;
    i?86) ARCH="386" ;;
    *) ARCH="$_arch_raw" ;;
  esac
fi
[ -n "${_arch_src:-}" ] || _arch_src="环境变量 ARCH"
echo "当前架构为 ${ARCH}/${_arch_raw:-$ARCH}（来源：${_arch_src}）"
ARCH="${ARCH:-unknown}"
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
  local core_arch
  case "${ARCH}" in
    amd64|x86_64) core_arch="amd64" ;;
    arm64|aarch64) core_arch="arm64" ;;
    armv7*|armv7l) core_arch="armv7" ;;
    386|i?86) core_arch="386" ;;
    *) core_arch="${ARCH}" ;;
  esac

  local core_ver
  local core_api
  core_api=$(curl -fsSL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" || true)
  core_ver=$(printf '%s' "$core_api" | awk -F '"' '{ if (!got) for (i=1;i<=NF;i++) if ($i=="tag_name") { v=$(i+2); got=1; break } } END { print v }')
  echo "OpenClash 核心：mihomo ${core_ver} (${core_arch})"
  [ -n "$core_ver" ] || return 1

  local core_url="https://github.com/MetaCubeX/mihomo/releases/download/${core_ver}/mihomo-linux-${core_arch}-${core_ver}.gz"

  download_ui "./luci-app-openclash/root/usr/share/openclash/ui/zashboard" || return 1

  cd ./luci-app-openclash/root/etc/openclash/ || return 1
  rm -f GeoSite.dat Country.mmdb

  local tmp_dir
  tmp_dir=$(mktemp -d)
  
  if curl -fsSL "$core_url" -o "$tmp_dir/core.gz" && gzip -dc "$tmp_dir/core.gz" > "$tmp_dir/clash_meta"; then
    local extracted_core
    extracted_core=$(head -c 4 "$tmp_dir/clash_meta" | od -An -tx1 | cut -c2-12)
    
    [ "$extracted_core" = "7f 45 4c 46" ] || { rm -rf "$tmp_dir"; return 1; }
    
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
  local agh_api
  agh_api=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest || true)
  agh_core=$(printf '%s' "$agh_api" | grep "browser_download_url" | grep -oE "https://[^\"]*AdGuardHome_linux_${ARCH}\.tar\.gz" | sed -n '1p')
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

  sed -i "s#__SINGBOX_URL__#${SINGBOX_URL}#g" ./sing-box/Makefile
  if grep -q "__SINGBOX_URL__" ./sing-box/Makefile; then
    echo "sing-box 下载地址注入失败"
    return 1
  fi

  return 0
}

check_tailscale() { [ -f "../feeds/packages/net/tailscale/Makefile" ]; }

handle_tailscale() {
  local ts_makefile="../feeds/packages/net/tailscale/Makefile"
  [ -f "$PATCH_DIR/tailscale/Makefile" ] || return 1

  local ts_repo="acnixuil/glinet-tailscale-updater"
  local ts_tag="tiny-noupx"
  local ts_base="https://github.com/${ts_repo}/releases/download/${ts_tag}"

  local ts_version
  local ts_txt
  ts_txt=$(curl -fsSL "${ts_base}/version.txt" || true)
  ts_version=$(printf '%s' "$ts_txt" | sed -n '1s/[[:space:]]*$//p')
  
  [ -n "$ts_version" ] || return 1

  local clean_version="${ts_version#v}"

  local target_arch
  case "${ARCH}" in
    "amd64" | "x86_64")
      target_arch="amd64"
      ;;
    "arm64" | "aarch64")
      target_arch="arm64"
      ;;
    *)
      target_arch="${ARCH}"
      ;;
  esac

  local ts_url="${ts_base}/tailscaled-linux-${target_arch}"

  local tmp_dir
  tmp_dir=$(mktemp -d)
  if curl -fsSL -o "${tmp_dir}/tailscaled" "${ts_url}"; then
    head -c 4 "${tmp_dir}/tailscaled" | od -An -tx1 | cut -c2-12 > "${tmp_dir}/magic.txt"

    [ "$(cat "${tmp_dir}/magic.txt")" = "7f 45 4c 46" ] || { rm -rf "${tmp_dir}"; return 1; }
    cp -f "${tmp_dir}/tailscaled" "${PATCH_DIR}/tailscale/" 2>/dev/null || true
    cp -f "${tmp_dir}/tailscale" "${PATCH_DIR}/tailscale/" 2>/dev/null || true
  else
    rm -rf "${tmp_dir}"
    return 1
  fi
  rm -rf "${tmp_dir}"

  cp -f "$PATCH_DIR/tailscale/Makefile" "$ts_makefile"

  sed -i "s/__VERSION__/${clean_version}/g" "$ts_makefile"
  sed -i "s#__URL__#${ts_url}#g" "$ts_makefile"

  return 0
}

check_lucky() { [ -d "./lucky" ]; }

handle_lucky() {
  [ -f "$PATCH_DIR/lucky/Makefile" ] || return 1
  [ -f "$PATCH_DIR/lucky/luckyuci" ] || return 1
  cp -f "$PATCH_DIR/lucky/Makefile" ./lucky/Makefile || return 1
  cp -f "$PATCH_DIR/lucky/luckyuci" ./lucky/files/luckyuci || return 1
  sed -i 's#^DEFAULT_CONFIG_DIR=.*#DEFAULT_CONFIG_DIR=/etc/lucky#' ./lucky/files/lucky.init || return 1
  grep -q 'LUCKY_PRODUCT:=xiaojv' ./lucky/Makefile || return 1
  grep -q 'PKG_VERSION:=3.8.0' ./lucky/Makefile || return 1
  grep -q "configdir '/etc/lucky'" ./lucky/files/luckyuci || return 1
  grep -q '^DEFAULT_CONFIG_DIR=/etc/lucky$' ./lucky/files/lucky.init || return 1

  local newest
  newest=$(curl -fsSL https://release.66666.host/ 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+(\.[0-9]+)?' | sort -uV | tail -n 1)
  newest="${newest#v}"
  if [ -n "$newest" ] && [ "$newest" != "3.8.0" ] && [ "$(printf '%s\n%s\n' 3.8.0 "$newest" | sort -V | tail -n 1)" = "$newest" ]; then
    echo "::warning::Lucky 发布站已有 ${newest}，本次仍编 3.8.0；升级只需改 patch/lucky/Makefile 的 PKG_VERSION 与两行 PKG_HASH"
  fi

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
    echo "### handlers.sh 处理结果"
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
run_step "Lucky 核心"   check_lucky        handle_lucky        required
run_step "sing-box"     check_singbox      handle_singbox      required
run_step "Tailscale"    check_tailscale    handle_tailscale    required
run_step "Argon 样式"   check_argon        handle_argon        optional
run_step "系统修补"     true               handle_syspatch     required

summary
[ "$FAILED" -gt 0 ] && echo "> 有可选步骤失败，但不阻断编译" 
exit 0