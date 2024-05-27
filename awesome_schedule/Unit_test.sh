#!/bin/bash

echo "Starting unit test"
flutter test ./test/widget_test.dart --coverage
genhtml coverage/lcov.info -o coverage/html

file_path="coverage/html/index.html"

# 检查文件是否存在
if [ -f "$file_path" ]; then
  # 打开文件
  open "$file_path"
else
  echo "File does not exist."
fi