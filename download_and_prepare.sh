#!/bin/sh

REPO_OWNER="DoL-Lyra"
REPO_NAME="Lyra"
PATTERN="besc-cheat-csd-hikari-ucb"

# 使用GitHub Token认证（自动注入）
curl_auth_header=""
if [ -n "$GIT_TOKEN" ]; then
  curl_auth_header="-H Authorization: Bearer $GIT_TOKEN"
fi

# 获取原始JSON并清理控制字符
LATEST_RELEASE=$(curl -sL $curl_auth_header \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest | \
  tr -cd '\11\12\15\40-\176')

# 保存原始响应用于调试
echo "$LATEST_RELEASE" > raw_response.json

# 精确匹配逻辑
ASSET_URL=$(echo "$LATEST_RELEASE" | jq -r \
  ".assets[] | select(.name | test(\"${PATTERN}.*\\.zip\$\"; \"i\")) | .browser_download_url")

# 调试输出
echo "Debug - Found asset URL: $ASSET_URL"
echo "Debug - Full assets list:"
echo "$LATEST_RELEASE" | jq -r '.assets[].name'

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
  echo "Error: Target asset not found"
  exit 1
fi

# 下载并处理（使用临时目录）
mkdir -p content
wget --show-progress -O build.zip "$ASSET_URL"
unzip -o build.zip -d content_temp
mv content_temp/* content/
rm -rf content_temp

# 验证文件存在性（处理空格）
if [ ! -f "content/Degrees of Lewdity.html" ]; then
  echo "Error: HTML file missing. Content list:"
  find content -maxdepth 1 -type f
  exit 1
fi

if [ ! -d "content/img" ]; then
  echo "Error: img directory missing. Content list:"
  find content -maxdepth 1 -type d
  exit 1
fi
