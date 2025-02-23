#!/bin/sh

# 获取最新 release 信息
RELEASE_JSON=$(curl -s https://api.github.com/repos/DoL-Lyra/Lyra/releases/latest)

# 解析包含 besc-hikari-ucb 的 zip 文件 URL
ZIP_URL=$(echo $RELEASE_JSON | jq -r '.assets[] | select(.name | contains("besc-hikari-ucb")) | .browser_download_url')

# 下载并解压
wget -q $ZIP_URL -O latest.zip
unzip -o latest.zip -d site
rm latest.zip
