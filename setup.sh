 #!/bin/bash
  # 超簡単セットアップ - ワンライナー対応

  # GitHubから直接実行可能
  # curl -sL https://raw.githubusercontent.com/tamikenn/codespace-autosave-kit/main/setup.sh | bash

  echo "🚀 Codespace AutoSave Kit - Quick Setup"

  # GitHubから最新版をダウンロードして実行
  INSTALLER_URL="https://raw.githubusercontent.com/tamikenn/codespace-autosave-kit/main/install.sh"

  # インストーラーをダウンロードして実行
  curl -sL "$INSTALLER_URL" -o /tmp/autosave-installer.sh
  chmod +x /tmp/autosave-installer.sh
  bash /tmp/autosave-installer.sh

  # クリーンアップ
  rm /tmp/autosave-installer.sh

  # 自動的にautosaveを開始
  source ~/.bashrc
  autosave &

  echo "✅ Setup complete and autosave started!"
