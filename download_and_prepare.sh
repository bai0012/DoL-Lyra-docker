#!/bin/sh

REPO_OWNER="DoL-Lyra"
REPO_NAME="Lyra"
PATTERN="besc-hikari-ucb"

# 使用原始JSON输出格式
LATEST_RELEASE=$(curl -sL -H "Accept: application/vnd.github.v3.raw" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest)

# 修复jq过滤器语法
ASSET_URL=$(echo "$LATEST_RELEASE" | jq -r \
  ".assets[] | select( (.name | contains(\"$PATTERN\")) and (.name | endswith(\".zip\")) ) | .browser_download_url")

# 增强调试输出
echo "Debug - RAW JSON Response:"
echo "$LATEST_RELEASE" | head -c 500  # 显示部分响应内容用于诊断

if [ -z "$ASSET_URL" ]; then
  echo "Error: No matching zip asset found. Available assets:"
  echo "$LATEST_RELEASE" | jq -r ".assets[].name" 2>/dev/null || echo "Failed to parse assets"
  exit 1
fi

# 下载并解压（增加重试机制）
wget --retry-connrefused --waitretry=30 --read-timeout=30 --timeout=30 -t 3 $ASSET_URL -O build.zip
unzip -o build.zip -d content

# 特殊字符处理验证
if [ ! -f "content/Degrees of Lewdity.html" ] || [ ! -d "content/img" ]; then
  echo "Error: Required files missing after extraction. Found:"
  find content -type f -print
  exit 1
fi
