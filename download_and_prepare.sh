#!/bin/sh

REPO_OWNER="DoL-Lyra"
REPO_NAME="Lyra"
PATTERN="besc-hikari-ucb"

# 增加HTTP头并优化JSON解析
LATEST_RELEASE=$(curl -sL -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest)

# 精确匹配zip文件
ASSET_URL=$(echo "$LATEST_RELEASE" | jq -r \
  ".assets[] | select(.name | contains(\"$PATTERN\") and (.name | endswith(\".zip\")) | .browser_download_url")

# 调试信息
if [ -z "$ASSET_URL" ]; then
  echo "Error: No matching zip asset found. Available assets:"
  echo "$LATEST_RELEASE" | jq -r ".assets[].name"
  exit 1
fi

# 下载并解压
wget $ASSET_URL -O build.zip
unzip -o build.zip -d content

# 验证必要文件存在（处理特殊文件名）
if [ ! -f "content/Degrees of Lewdity.html" ] || [ ! -d "content/img" ]; then
  echo "Error: Required files missing after extraction. Content list:"
  ls -R content
  exit 1
fi
