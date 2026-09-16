# pin-game (Rojoプロジェクト)

移植元: `roborobo20268` アカウントの「20260910ピン」プレース

## フォルダ構成
- `src/shared` → `ReplicatedStorage/Shared` に同期
- `src/server` → `ServerScriptService/Server` に同期
- `src/client` → `StarterPlayer/StarterPlayerScripts/Client` に同期
- `default.project.json` → Rojoの同期設定

## セットアップ手順

### 1. Roblox Studio側で.rbxlを移植(先にやること)
1. `roborobo20268` アカウントでStudioにログインし、対象プレース(「20260910ピン」)を開く(現在この状態)。
2. `ファイル → コピーをダウンロード` でローカルに `.rbxl` として保存(例: デスクトップに `pin.rbxl`)。
   ※クラウド保存のプレースの場合、通常の「名前を付けて保存」は表示されず「コピーをダウンロード」がローカル書き出しに相当する。
3. Studioを終了し、移植先アカウントでログインし直す。
4. `ファイルを開く` で保存した `.rbxl` を開く。

### 2. Rojo CLI(インストール済み)
Aftman経由でこのプロジェクトに `rojo 7.7.0` を導入済み(`aftman.toml` 参照)。
新しいターミナルでPATHが通っていない場合は以下で確認:

```powershell
rojo --version
```

反応しない場合はPowerShellを再起動するか、`%USERPROFILE%\.aftman\bin` をPATHに追加してください。

### 3. Roblox Studio側にRojoプラグインを導入
1. Studioを開く。
2. `ツールボックス` (Toolbox) で "Rojo" を検索してインストール、または
   `https://create.roblox.com/store/asset/13916111004/Rojo` からプラグインを取得。
3. Studio右上のプラグインタブに "Rojo" アイコンが表示されればOK。

### 4. サーバー起動 & 接続
このフォルダで:

```powershell
rojo serve
```

Studio側のRojoプラグインで `Connect` をクリック(デフォルトポート 34872)。
これで `src/` 以下の変更がリアルタイムでStudioに反映される。

### 5. 既存スクリプトの取り込み
Rojoは基本的に「新規に置くスクリプトをファイルシステム側で管理する」仕組みのため、
既存の.rbxl内のスクリプトは**手動でコピー&ペースト**して `src/` 配下に `.lua` ファイルとして書き出す必要がある
(マップ・パーツ・モデルなどは引き続き.rbxl側で管理し、Rojoでは同期しない)。

1. Studioのエクスプローラーで既存スクリプトを開く。
2. 中身をコピーし、対応する `src/server` や `src/client` や `src/shared` 配下に `.lua` ファイルとして保存。
   - `Script` → `src/server/xxx.server.lua`
   - `LocalScript` → `src/client/xxx.client.lua`
   - `ModuleScript` → `src/shared/xxx.lua`
3. 元のStudio上のスクリプトは削除してよい(Rojo同期後は自動生成されるため)。

## 今後の開発フロー
1. Claude Codeで `src/` 配下のLuaファイルを編集。
2. `rojo serve` を起動したままにしておけば、保存と同時にStudioへ反映される。
3. 動作確認はStudioのプレイテストで行う。
