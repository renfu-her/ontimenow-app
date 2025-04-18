# OnTimeNow - 多功能時鐘應用

這是一個以 Flutter 開發的多功能時鐘應用，支援繁體中文，包含鬧鐘、時鐘、計時器、碼表等功能。

## 主要功能

### 鬧鐘
- 新增、編輯、刪除鬧鐘
- 支援自訂標籤、時間、重複週期
- 每個鬧鐘可自選鈴聲並可預聽
- 鬧鐘響起時會彈窗提示
- 支援貪睡功能
- 鬧鐘資料會自動儲存於本地

### 時鐘
- 顯示本地時間與日期
- 支援世界時鐘（預設倫敦、紐約、東京）

### 計時器
- 可新增多個計時器
- 支援開始、暫停、重設、刪除
- 進度條顯示剩餘時間

### 碼表
- 支援開始、暫停、重設
- 支援圈數記錄

## 安裝與執行

1. 安裝 Flutter 環境
   - 請參考 [Flutter 官方文件](https://flutter.dev/docs/get-started/install)

2. 下載專案並安裝依賴
   ```bash
   git clone <你的 repo 位置>
   cd ontimenow-app
   flutter pub get
   ```

3. 確保 assets/sounds 目錄下有所有鈴聲檔案

4. 執行 App
   ```bash
   flutter run
   ```

## 主要套件
- shared_preferences — 本地資料儲存
- audioplayers — 鬧鐘鈴聲播放
- intl — 日期時間格式化
- flutter_localizations — 多語系支援

## 其他說明
- 本專案預設語系為繁體中文（台灣）
- 若需擴充世界時鐘、鬧鐘鈴聲或其他功能，請參考 lib/pages/ 及 assets/sounds/ 目錄結構
