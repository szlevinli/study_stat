#!/bin/bash
set -e  # 遇到错误立即退出

# 0. 修复 uv 缓存目录权限（如果使用 volume mount）
if [ -d /home/vscode/.cache/uv ]; then
    sudo chown -R vscode:vscode /home/vscode/.cache/uv || true
    sudo chmod -R 755 /home/vscode/.cache/uv || true
fi

# 0.1. 设置 SSH 目录权限（SSH 对权限要求很严格）
if [ -d /home/vscode/.ssh ]; then
    # 确保目录权限正确
    sudo chown -R vscode:vscode /home/vscode/.ssh || true
    sudo chmod 700 /home/vscode/.ssh || true
    # 设置私钥文件权限（SSH 要求必须是 600）
    if [ -f /home/vscode/.ssh/id_rsa ]; then
        sudo chmod 600 /home/vscode/.ssh/id_rsa || true
    fi
    if [ -f /home/vscode/.ssh/id_ed25519 ]; then
        sudo chmod 600 /home/vscode/.ssh/id_ed25519 || true
    fi
    # 设置公钥和 config 文件权限
    sudo chmod 644 /home/vscode/.ssh/*.pub 2>/dev/null || true
    sudo chmod 644 /home/vscode/.ssh/config 2>/dev/null || true
    sudo chmod 600 /home/vscode/.ssh/known_hosts 2>/dev/null || true
fi

# 1. 安装 uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. 初始化项目（如果不存在 pyproject.toml）
if [ ! -f pyproject.toml ]; then
    /home/vscode/.local/bin/uv init --app
fi


# 3. 安装开发工具
/home/vscode/.local/bin/uv add --dev ruff mypy ipykernel nbstripout

# 4. 同步依赖
/home/vscode/.local/bin/uv sync

# 5. 配置 nbstripout Git 过滤器（如果项目是 Git 仓库）
if [ -d .git ]; then
    export PATH=$HOME/.local/bin:$PATH
    /home/vscode/.local/bin/uv run nbstripout --install || true
    # 使用 || true 避免如果已经安装过导致脚本失败
fi