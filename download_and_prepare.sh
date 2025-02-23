#!/bin/bash

REPO_OWNER="DoL-Lyra"
REPO_NAME="Lyra"
PATTERN="besc-hikari-ucb"

# 使用原始JSON格式并清理控制字符
LATEST_RELEASE=$(curl -sL \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer ${GIT_TOKEN}" \
  "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" | \
  tr -d '\000-\031')

# 精确匹配逻辑（使用完全正则表达式）
ASSET_URL=$(echo "${LATEST_RELEASE}" | jq -r \
  ".assets[] | select(.name | test(\"${PATTERN}.*\\.zip$\"; \"i\")) | .browser_download_url")

# 调试输出
echo "=== DEBUG INFORMATION ==="
echo "GIT_TOKEN: ${GIT_TOKEN:0:4}****"  # 安全显示token
echo "PATTERN: ${PATTERN}"
echo "ASSET_URL: ${ASSET_URL}"
echo "FULL ASSET LIST:"
echo "${LATEST_RELEASE}" | jq -r '.assets[].name' | grep -iE 'zip$'

if [[ -z "${ASSET_URL}" || "${ASSET_URL}" == "null" ]]; then
  echo "##[error]ERROR: Target asset not found"
  echo "${LATEST_RELEASE}" > debug_response.json
  exit 1
fi

# 下载并处理
mkdir -p content
echo "Downloading: ${ASSET_URL}"
wget --retry-connrefused --waitretry=30 --progress=dot:giga "${ASSET_URL}" -O build.zip

# 解压并处理特殊字符
echo "Unzipping files..."
unzip -O UTF-8 -o build.zip -d content_temp

# 处理可能的顶层目录
if [ $(ls -1 content_temp | wc -l) -eq 1 ]; then
  mv content_temp/*/* content/
else
  mv content_temp/* content/
fi
rm -rf content_temp

# 验证关键文件
required_files=(
  "Degrees of Lewdity.html"
  "img/"
)

for item in "${required_files[@]}"; do
  if [[ "${item}" =~ /$ ]]; then
    if [ ! -d "content/${item%/}" ]; then
      echo "##[error]ERROR: Directory ${item} missing"
      find content -maxdepth 1 | sed 's/^/  /'
      exit 1
    fi
  else
    if [ ! -f "content/${item}" ]; then
      echo "##[error]ERROR: File ${item} missing"
      find content -maxdepth 1 -type f | sed 's/^/  /'
      exit 1
    fi
  fi
done

echo "Content verification passed!"
tree -L 2 content
