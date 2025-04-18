# 遲到剋星 - 多功能時鐘應用

**遲到剋星** 是一款以 Flutter 開發的跨平台多功能時鐘應用，完整支援繁體中文，集成：鬧鐘、時鐘（本地 & 世界時鐘）、計時器、碼表等功能，並提供自訂鈴聲、重複提醒、貪睡、持續通知等實用特性。

## 功能特色

### 鬧鐘 Alarm
- 新增、編輯、刪除鬧鐘
- 自訂標籤 (Label)、時間、重複週期（星期日~六）
- **持續提醒**：勾選後於鬧鐘前 10 分鐘、5 分鐘彈窗提示並播放鈴聲
- 貪睡功能：鬧鐘響起時可延後再次提醒
- 到點僅顯示一次鬧鐘對話框，鈴聲會持續播放直至按下「已經出門了」或手動關閉
- 一次性鬧鐘按「已經出門了」後會自動停用，重複鬧鐘則保留設定
- 本地化資料儲存 (shared_preferences)，重啟後保留所有鬧鐘設定

### 時鐘 Clock
- 顯示本地數字時間與日期
- 圓形指針時鐘 + 數字雙重顯示
- 世界時鐘：默認台北、倫敦、紐約、東京，可左右滑動卡片瀏覽
- 每秒自動更新

### 計時器 Timer
- 支援多組計時器同時運行
- 開始 / 暫停 / 重設 / 刪除
- 倒數進度實時顯示

### 碼表 Stopwatch
- 支援開始 / 暫停 / 重置
- 圈數記錄與查看

### 主題與 UI
- Material 3 主題配置
- 自訂配色：酒紅色 (Primary) + 青色 (Secondary)
- AppBar、Button、卡片等組件統一樣式
- Clara 簡潔現代設計風格

## 安裝與使用

1. 環境需求
   - Flutter SDK 3.x 以上
   - 開發 IDE：Android Studio / VSCode

2. 取得程式碼
   ```bash
   git clone <repo-url>
   cd ontimenow-app
   ```

3. 安裝套件
   ```bash
   flutter pub get
   ```

4. 準備資源
   - `assets/sounds/`：放入 `alert.mp3`, `bell.mp3`, `digital.mp3` 等鈴聲檔
   - `assets/images/`：放置應用圖示、ICON
   - `pubspec.yaml` 已預先配置

5. 運行 App
   ```bash
   flutter run
   ```

## 專案結構
```
lib/
├── main.dart               # App 入口、主題與全局配置
├── models/
│   └── alarm_model.dart    # Alarm 資料模型與本地儲存邏輯
├── pages/
│   ├── alarm_page.dart     # 鬧鐘頁面
│   ├── clock_page.dart     # 時鐘頁面 (本地 + 世界)
│   ├── timer_page.dart     # 計時器頁面
│   └── stopwatch_page.dart # 碼表頁面
├── widgets/                # 可重用組件
└── utils/                  # 工具函式
```

## 使用套件
- `provider`：狀態管理
- `shared_preferences`：本地儲存
- `audioplayers`：音效播放
- `intl`：日期時間格式化
- `flutter_localizations`：多語系支持

## 未來優化
- 深色模式主題
- 更多世界時鐘城市列表
- 鈴聲音量及靜音控制
- 推播通知整合

## 聯絡與貢獻
歡迎提交 issue 或 PR，如有任何建議與問題請聯繫作者。
