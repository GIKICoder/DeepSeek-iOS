#!/bin/bash

# 检查是否提供了目录参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# 设置目录变量
TARGET_DIR="$1"

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# 删除所有 .m 文件
find "$TARGET_DIR" -type f -name "*.h" -delete

echo "所有 .h 文件已从 '$TARGET_DIR' 及其子目录中删除。"
