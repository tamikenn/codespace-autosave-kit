  #!/bin/bash
  # コアファイル - auto-save-system.sh
  # これは完全版のauto-save-system.shのコピー

  # 設定
  REPO_DIR="$(pwd)"
  BACKUP_INTERVAL=300  # 5分ごと
  COMMIT_INTERVAL=900  # 15分ごと
  LOG_FILE="$HOME/.codespace-autosave/.autosave.log"

  # ディレクトリ作成
  mkdir -p "$HOME/.codespace-autosave"

  # Git設定
  git config user.name "Auto Save System" 2>/dev/null
  git config user.email "autosave@codespaces.local" 2>/dev/null

  # 色付き出力
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'

  # ログ関数
  log_info() {
      echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
  }

  log_warn() {
      echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}" | tee -a "$LOG_FILE"
  }

  # 初期バックアップ
  initial_backup() {
      log_info "初期バックアップ実行中..."
      git add -A 2>/dev/null
      if git diff --staged --quiet 2>/dev/null; then
          log_info "変更なし - スキップ"
      else
          git commit -m "Initial backup: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null
          log_info "✓ 初期バックアップ完了"
      fi
  }

  # 自動保存ループ
  auto_save_loop() {
      local last_commit_time=$(date +%s)

      while true; do
          current_time=$(date +%s)

          # 変更があるかチェック
          if ! git diff --quiet 2>/dev/null || ! git diff --staged --quiet 2>/dev/null; then
              git add -A 2>/dev/null
              time_since_commit=$((current_time - last_commit_time))

              if [ $time_since_commit -ge $COMMIT_INTERVAL ]; then
                  if ! git diff --staged --quiet 2>/dev/null; then
                      commit_msg="Auto-save: $(date '+%Y-%m-%d %H:%M:%S')"
                      git commit -m "$commit_msg" 2>/dev/null
                      log_info "📝 自動コミット: $commit_msg"
                      last_commit_time=$current_time

                      if git push 2>/dev/null; then
                          log_info "☁️  リモートに同期完了"
                      fi
                  fi
              fi
          fi

          sleep $BACKUP_INTERVAL
      done
  }

  # 緊急保存
  emergency_save() {
      log_warn "緊急保存実行中..."
      git add -A 2>/dev/null
      if ! git diff --staged --quiet 2>/dev/null; then
          git commit -m "EMERGENCY SAVE: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null
          git push 2>/dev/null || true
          log_info "✓ 緊急保存完了"
      fi
      exit 0
  }

  trap emergency_save SIGINT SIGTERM

  # メイン
  main() {
      cd "$REPO_DIR"
      log_info "=== 自動保存システム起動 ==="
      initial_backup

      echo ""
      echo "╔════════════════════════════════════════╗"
      echo "║   🔒 自動保存システム稼働中            ║"
      echo "╠════════════════════════════════════════╣"
      echo "║   保存間隔: 5分ごと                    ║"
      echo "║   コミット: 15分ごと                   ║"
      echo "║   緊急保存: Ctrl+C                     ║"
      echo "╚════════════════════════════════════════╝"
      echo ""

      auto_save_loop
  }

  main
