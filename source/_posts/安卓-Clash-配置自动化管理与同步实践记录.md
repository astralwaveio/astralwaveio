---
title: 安卓 Clash 配置自动化管理与同步实践记录
date: 2025-06-06 20:00:00
categories:
  - Android
  - 自动化
tags:
  - Clash
  - Magisk
  - Termux
  - 配置管理
---

# 安卓 Clash 配置自动化管理与同步实践记录

最近在 OnePlus 设备上基于 [box_for_magisk](https://github.com/taamarin/box_for_magisk) 做 Clash 管理和魔改。为提升多设备与多场景同步的灵活性，决定通过 Git 仓库和软链接自动化配置同步，并结合 termux 实现定时自动化 pull&deploy。本文是完整的实现步骤记录。

## 目标

- 所有 Clash、全局等自定义配置集中管理到 `surfing-config` 仓库。
- 仓库内容实际存放在 `/storage/emulated/0/Android/surfing-config/`。
- 通过软链接将配置映射到 `/data/adb/box/` 及子目录，实现无缝切换。
- 利用 termux 和 cron 自动同步配置，彻底实现“只维护仓库文件”。

## 步骤

### 1. 配置迁移

将 `/data/adb/box/clash/config.yaml`、`provide/`、`/data/adb/box/settings.ini`、`ap.list.cfg` 等复制到 surfing-config 目录下，冗余和运行时文件不做同步。

### 2. 仓库结构与 .gitignore

通过 `.gitignore` 只允许自定义配置纳入管理，其他全部忽略，防止杂项干扰。


```gitignore
*
!.gitignore
!README.md
!bin/
!bin/link-surfing-config.sh
!clash/
!clash/config.yaml
!clash/provide/
!clash/provide/**
!settings.ini
!ap.list.cfg
````

### 3. 自动化软链接脚本

所有操作通过 `bin/link-surfing-config.sh` 完成，包含自动 git pull、清理旧链接、重建新软链接。脚本支持多次运行，无需人工干预，适合定时任务。

### 4. 安全目录设置

由于安卓下常遇到 git “dubious ownership” 报错，需全局加入 safe.directory：

```sh
git config --system --add safe.directory /storage/emulated/0/Android/surfing-config
```

### 5. 定时自动同步

借助 termux 的 cronie，配置定时任务实现每小时自动同步并软链：

```cron
0 * * * * /system/bin/sh /storage/emulated/0/Android/surfing-config/bin/link-surfing-config.sh
```

## 总结

至此，所有 clash 及相关自定义配置均通过 git 仓库和软链自动化维护，极大提升了配置同步的可靠性和效率。只要更新仓库内容，手机侧无需手动干预即可自动应用到实际环境，极其适合需要跨设备/多环境的技术用户。

---
