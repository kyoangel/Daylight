# Daylight 資料結構與本機儲存模型

本文件整理目前在本機（SharedPreferences）儲存的資料結構、鍵值與版本控制方式，方便後續擴充與遷移。

## 版本控制
- Key: `data_version`
- 類型: `int`
- 目前最新版本: `1`
- 遷移流程由 `lib/data/storage/data_migrator.dart` 控制

## 主要資料表（Key -> JSON 結構）

### `user_profile`
```json
{
  "nickname": "string",
  "avatarUrl": "string | null",
  "themeColorHex": "string",
  "language": "string",
  "reminderTimes": ["string"],
  "preferredModes": ["string"],
  "triggers": ["string"],
  "moodBaseline": 0
}
```

### `onboarding_state`
```json
{
  "step": 0,
  "completed": false
}
```

### `daily_entries`
```json
[
  {
    "date": "YYYY-MM-DD",
    "moodScore": 0,
    "microTaskId": "string",
    "microTaskDone": false,
    "affirmationId": "string",
    "nightReflection": "string"
  }
]
```

### `diary_entries`
```json
[
  {
    "id": "string",
    "date": "ISO-8601",
    "moodTag": "string",
    "template": "string",
    "content": "string"
  }
]
```

### `companion_sessions`
```json
[
  {
    "id": "string",
    "mode": "string",
    "startAt": "ISO-8601",
    "endAt": "ISO-8601",
    "summary": "string"
  }
]
```

### `sos_contacts`
```json
[
  {
    "name": "string",
    "phone": "string",
    "messageTemplate": "string"
  }
]
```

## 遷移策略
- 所有新的 schema 變更都要透過 `DataMigrator` 增量升版
- 每次新增版本時：
  - 更新 `latestVersion`
  - 加入對應的 `_migrateToV{N}` 方法
  - 保持舊資料向後相容或提供預設值補齊
