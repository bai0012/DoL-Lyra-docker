#!/bin/sh

REPO_OWNER="DoL-Lyra"
REPO_NAME="Lyra"
PATTERN="besc-hikari-ucb"

# 获取最新release的资产信息
LATEST_RELEASE=$(curl -sL https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest)
ASSET_URL=$(echo $LATEST_RELEASE | jq -r ".assets[] | select(.name | contains(\"$PATTERN\")) | .browser_download_url")

if [ -z "$ASSET_URL" ]; then
  echo "Error: No asset containing '$PATTERN' found in latest release"
  exit 1
fi

# 下载并解压
wget $ASSET_URL -O build.zip
unzip -o build.zip -d content

# 验证必要文件存在
if [ ! -f "content/Degrees of Lewdity.html" ] || [ ! -d "content/img" ]; then
  echo "Error: Required files missing after extraction"
  exit 1
fi
