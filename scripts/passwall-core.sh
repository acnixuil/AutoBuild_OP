#!/bin/bash
rm -rf feeds/luci/applications/luci-app-passwall
./scripts/feeds install -a -f -p passwall_packages
./scripts/feeds install -a -f -p passwall_luci   