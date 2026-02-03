# Daylight 資料結構與本機儲存模型（P0）

更新日期：2026-02-03

## 目標
- 支援 P0 主要功能：Onboarding、Daily、Diary、Companion（基礎）、SOS、Profile
- 優先採用本機儲存（SharedPreferences / 本機 JSON）
- 後續可平滑升級到雲端同步

---

## 儲存策略（P0）
- 個人設定與偏好：SharedPreferences（key-value）
- 日常/日記等時序資料：本機 JSON（或 SharedPreferences 的 JSON 字串）
- 建議加上一個版本號，方便未來資料遷移

---

## 核心資料模型

### 1. UserProfile
- 用途：使用者基本資料與偏好

```json
{
  "nickname": "",
  "avatarUrl": "",
  "themeColorHex": "#75C9E0",
  "language": "zh-TW",
  "reminderTimes": ["08:30", "21:00"],
  "preferredModes": ["text", "micro-task"],
  "triggers": ["lonely", "body_pain"],
  "moodBaseline": 5
}
```

### 2. OnboardingState
- 用途：保存 onboarding 進度

```json
{
  "step": 2,
  "completed": false
}
```

### 3. DailyEntry
- 用途：每日心情打卡與小任務

```json
{
  "date": "2026-02-03",
  "moodScore": 6,
  "microTaskId": "task_001",
  "microTaskDone": true,
  "affirmationId": "aff_011",
  "nightReflection": "今天覺得比較平靜。"
}
```

### 4. DiaryEntry
- 用途：情緒日記

```json
{
  "id": "diary_20260203_001",
  "date": "2026-02-03",
  "moodTag": "calm",
  "template": "gratitude",
  "content": "今天想感謝自己願意出門走走。"
}
```

### 5. CompanionSession
- 用途：陪伴對話（P0 僅本機保存簡化）

```json
{
  "id": "comp_20260203_001",
  "mode": "listen",
  "startAt": "2026-02-03T10:00:00Z",
  "endAt": "2026-02-03T10:10:00Z",
  "summary": "完成陪伴 10 分鐘"
}
```

### 6. SOSContact
- 用途：緊急聯絡人

```json
{
  "name": "朋友 A",
  "phone": "+886900000000",
  "messageTemplate": "我現在需要幫助，可以陪我一下嗎？"
}
```

---

## 本機儲存 key 設計（建議）

| Key | 類型 | 內容 |
| --- | --- | --- |
| user_profile | JSON | UserProfile |
| onboarding_state | JSON | OnboardingState |
| daily_entries | JSON Array | DailyEntry[] |
| diary_entries | JSON Array | DiaryEntry[] |
| companion_sessions | JSON Array | CompanionSession[] |
| sos_contacts | JSON Array | SOSContact[] |
| data_version | string | 版本號（如 1.0） |

---

## 版本與遷移
- `data_version` 預設為 `1.0`
- 未來如增加欄位，需加上遷移邏輯（例如缺欄位時補預設值）

---

## 下一步（可接續）
- 為每個模型建立 Dart class + fromJson/toJson
- 建立 Repository 層與本機儲存服務
- 新增單元測試：
  - JSON encode/decode
  - Repository 存取

