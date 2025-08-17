  ⎿ #!/bin/bash                                                                                    
    # Codespace AutoSave Kit - Universal Installer
    # One-command setup for any GitHub Codespace

    set -e

    # 色付き出力
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'

    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Codespace AutoSave Kit Installer    ║${NC}"
    echo -e "${BLUE}║        v1.0 - Universal Setup          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # インストール先ディレクトリ
    INSTALL_DIR="$HOME/.codespace-autosave"
    REPO_URL="https://raw.githubusercontent.com/tamikenn/codespace-autosave-kit/main"

    # 1. ディレクトリ作成
    echo -e "${YELLOW}[1/5]${NC} Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    # 2. 必要なファイルをダウンロード
    echo -e "${YELLOW}[2/5]${NC} Downloading components..."

    # コアスクリプト
    curl -sL "$REPO_URL/core/auto-save-system.sh" -o auto-save-system.sh
    curl -sL "$REPO_URL/core/instant-save.sh" -o instant-save.sh
    curl -sL "$REPO_URL/core/keep-alive.sh" -o keep-alive.sh
    curl -sL "$REPO_URL/core/ultimate-keepalive.sh" -o ultimate-keepalive.sh

    # 設定ファイル
    mkdir -p configs
    curl -sL "$REPO_URL/configs/vscode-settings.json" -o configs/vscode-settings.json
    curl -sL "$REPO_URL/configs/git-config.sh" -o configs/git-config.sh

    # 権限設定
    chmod +x *.sh configs/*.sh

    # 3. VSCode設定を適用
    echo -e "${YELLOW}[3/5]${NC} Configuring VSCode..."
    VSCODE_DIR="$HOME/.vscode-server/data/Machine"
    mkdir -p "$VSCODE_DIR"

    # 既存の設定とマージ
    if [ -f "$VSCODE_DIR/settings.json" ]; then
        # jqがあれば使用、なければ単純追加
        if command -v jq &> /dev/null; then
            jq -s '.[0] * .[1]' "$VSCODE_DIR/settings.json" configs/vscode-settings.json >
    "$VSCODE_DIR/settings.json.tmp"
            mv "$VSCODE_DIR/settings.json.tmp" "$VSCODE_DIR/settings.json"
        else
            cp configs/vscode-settings.json "$VSCODE_DIR/settings.json"
        fi
    else
        cp configs/vscode-settings.json "$VSCODE_DIR/settings.json"
    fi

    # プロジェクトローカル設定も更新
    if [ -d "$(pwd)/.vscode" ]; then
        cp configs/vscode-settings.json "$(pwd)/.vscode/settings.json"
    fi

    # 4. Git設定
    echo -e "${YELLOW}[4/5]${NC} Configuring Git..."
    bash configs/git-config.sh

    # 5. エイリアス設定
    echo -e "${YELLOW}[5/5]${NC} Setting up aliases..."

    # bashrcに追加
    cat >> "$HOME/.bashrc" << 'EOF'

    # Codespace AutoSave Kit Aliases
    alias autosave='$HOME/.codespace-autosave/auto-save-system.sh'
    alias quicksave='git add -A && git commit -m "Quick save: $(date +%Y-%m-%d\ %H:%M:%S)" && git 
    push'
    alias savelog='tail -f $HOME/.codespace-autosave/.autosave.log'
    alias keepalive='$HOME/.codespace-autosave/ultimate-keepalive.sh'

    # 自動起動設定（オプション）
    # Uncomment to auto-start on shell login
    # if [ -z "$AUTOSAVE_STARTED" ]; then
    #     export AUTOSAVE_STARTED=1
    #     nohup $HOME/.codespace-autosave/auto-save-system.sh > /dev/null 2>&1 &
    #     echo "AutoSave system started in background (PID: $!)"
    # fi
    EOF

    # 6. systemdサービス作成（オプション）
    if command -v systemctl &> /dev/null && [ -d "$HOME/.config/systemd/user" ]; then
        echo -e "${GREEN}Creating systemd service...${NC}"

        cat > "$HOME/.config/systemd/user/codespace-autosave.service" << EOF
    [Unit]
    Description=Codespace AutoSave System
    After=network.target

    [Service]
    Type=simple
    ExecStart=$HOME/.codespace-autosave/auto-save-system.sh
    Restart=always
    RestartSec=10
    WorkingDirectory=%h

    [Install]
    WantedBy=default.target
    EOF

        systemctl --user daemon-reload
        echo "To enable auto-start: systemctl --user enable codespace-autosave"
    fi

    # 完了メッセージ
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✅ Installation Complete!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Available Commands:${NC}"
    echo "  autosave    - Start auto-save system"
    echo "  quicksave   - Instantly save all changes"
    echo "  savelog     - View save activity log"
    echo "  keepalive   - Start keep-alive system"
    echo ""
    echo -e "${YELLOW}Quick Start:${NC}"
    echo "  1. Reload shell: source ~/.bashrc"
    echo "  2. Start autosave: autosave"
    echo ""
    echo -e "${GREEN}Enjoy worry-free coding!${NC}"
