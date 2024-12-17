#!/bin/bash
# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # 无色
# 设置 Git 用户信息（如果未设置的话）
git config --global user.email "jonny6015@icloud.com"
git config --global user.name "Astral Wave"

# 拉取远程更新
if ! git pull origin main; then
    echo -e "${RED}拉取远程更新失败，正在处理冲突...${NC}"
    
    # 检查是否有冲突
    if git status | grep -q "Unmerged paths"; then
        echo -e "${RED}检测到冲突，正在解决冲突...${NC}"
        # 解决冲突，保留本地修改
        git checkout --ours . 
        git add .
        
        # 提交合并
        git commit -m "已解决合并冲突，保留本地更改"
    fi
fi
# 添加所有更改并提交
git add .
# 提交更改
if git commit -m "在 $(date) 自动提交"; then
    echo -e "${GREEN}提交成功！${NC}"
else
    echo -e "${RED}没有更改需要提交${NC}"
fi
# 推送到远程
if git push origin main; then
    echo -e "${GREEN}推送成功！${NC}"
else
    echo -e "${RED}推送失败，请检查远程仓库设置${NC}"
fi