class AppStrings {
  AppStrings._(this._locale);

  final String _locale;

  static AppStrings of(String locale) => AppStrings._(locale);

  bool get isEnglish => _locale == 'en';

  String get appTitle => isEnglish ? 'Daylight' : '一日之光';
  String get navDaily => isEnglish ? 'Daily' : '日常';
  String get navCompanion => isEnglish ? 'Companion' : '陪伴';
  String get navDiary => isEnglish ? 'Mindfulness' : '正念引導';
  String get navProfile => isEnglish ? 'Me' : '我';

  String get profileTitle => isEnglish ? 'Profile' : '個人';
  String get nicknameLabel => isEnglish ? 'Nickname' : '暱稱';
  String get save => isEnglish ? 'Save' : '儲存';
  String get themeColor => isEnglish ? 'Theme Color' : '主題色';
  String get languageLabel => isEnglish ? 'Language' : '語言';
  String get reminderTimesLabel => isEnglish ? 'Reminder times' : '提醒時段（可多選）';
  String get preferredInteractionLabel =>
      isEnglish ? 'Preferred interaction (multi-select)' : '互動方式（多選）';
  String get triggersLabel => isEnglish ? 'Triggers (multi-select)' : '觸發源（多選）';
  String get moodBaselineLabel => isEnglish ? 'Mood baseline' : '心情基準';
  String get toneLabel => isEnglish ? 'Support tone' : '陪伴語氣';
  String get languageToggleLabel => isEnglish ? 'App language' : '語言切換';

  String get onboardingWelcome => isEnglish ? 'Welcome' : '歡迎';
  String get onboardingWelcomeBody =>
      isEnglish
          ? 'You are not alone. We will walk with you.'
          : '你不是一個人，我們陪你走一小步';
  String get onboardingStart => isEnglish ? 'Start' : '開始';
  String get onboardingBasic => isEnglish ? 'Basics' : '基本設定';
  String get onboardingPreferences => isEnglish ? 'Preferences' : '情緒偏好';
  String get onboardingSafety => isEnglish ? 'Safety' : '安全提示';
  String get onboardingNext => isEnglish ? 'Next' : '下一步';
  String get onboardingBack => isEnglish ? 'Back' : '上一步';
  String get onboardingEnter => isEnglish ? 'Enter' : '進入首頁';
  String get safetyHint =>
      isEnglish
          ? 'This is not a medical service. Use SOS if you need urgent help.'
          : '這不是醫療服務，如有緊急狀況請使用 SOS。';

  String get dailyTitle => isEnglish ? 'Mood Daily' : '心情日記';
  String get weeklyTrend => isEnglish ? 'Weekly Mood Trend' : '本週心情趨勢';
  String get noRecords => isEnglish ? 'No records yet' : '尚無紀錄';
  String get todayMood => isEnglish ? 'Today Mood' : '今日心情';
  String get todayTask => isEnglish ? 'Today Task' : '今日小任務';
  String get todayAffirmation => isEnglish ? "Today's Affirmation" : '今日肯定語';
  String get gratitudeTitle => isEnglish ? 'Gratitude note' : '感恩小記';
  String get gratitudeHint =>
      isEnglish ? 'Write one small grateful thing...' : '寫下一件讓你感到感恩的小事...';
  String get gratitudeSave => isEnglish ? 'Save gratitude' : '記錄感恩';
  String get gratitudeEmpty =>
      isEnglish ? 'No gratitude notes yet.' : '目前沒有感恩小記';
  String get gratitudeSaved => isEnglish ? 'Saved.' : '已記錄感恩小記';
  String get gratitudeViewAll => isEnglish ? 'View all' : '查看全部';
  String get gratitudeAllTitle => isEnglish ? 'All gratitude notes' : '所有感恩小記';
  String get noTask => isEnglish ? 'No tasks yet' : '尚無任務內容';
  String get noAffirmation => isEnglish ? 'No affirmations yet' : '尚無肯定語';
  String get nightReflection => isEnglish ? 'Night Reflection' : '晚安反思';
  String get reflectionHint =>
      isEnglish ? 'What moment felt a bit lighter today?' : '今天哪一刻你覺得稍微輕鬆？';
  String get saveToday => isEnglish ? 'Save Today' : '保存今日';
  String get savedToday => isEnglish ? 'Saved today' : '今日已保存';
  String get playAudio => isEnglish ? 'Play audio' : '播放引導錄音';
  String get audioMissing => isEnglish ? 'Audio not available yet.' : '尚未提供錄音檔';
  String get welcomeFallbackGreeting =>
      isEnglish ? 'I am here with you.' : '我在這裡陪你。';
  String get welcomeFallbackDirection =>
      isEnglish ? 'Just one small step is enough.' : '今天只要一小步就好。';
  String get toneShortDirection =>
      isEnglish ? 'One small step is enough.' : '今天只要一小步就好。';
  String get toneGentleGreetingTail =>
      isEnglish ? ' Take your time.' : ' 慢慢來就好。';
  String get toneEncourageGreetingTail =>
      isEnglish ? ' You can do this.' : ' 你做得到。';
  String get toneEncourageDirectionTail =>
      isEnglish ? ' I believe in you.' : ' 我相信你。';
  String get toneGentleAffirmationPrefix =>
      isEnglish ? 'A gentle reminder: ' : '溫柔提醒：';
  String get toneEncourageAffirmationPrefix =>
      isEnglish ? 'Let’s keep going: ' : '一起加油：';
  String get softInterventionTitle =>
      isEnglish ? 'Would a gentle moment help?' : '需要一點溫柔的陪伴嗎？';
  String get softInterventionBody =>
      isEnglish
          ? 'You have been carrying a lot lately. We can keep it small.'
          : '最近辛苦了，我們把步伐放小一點。';
  String get close => isEnglish ? 'Close' : '關閉';
  String get nightlyClosingTitle => isEnglish ? 'Good night' : '晚安結語';
  String get nightlyClosingBodyGentle =>
      isEnglish ? 'You did enough for today. Rest now.' : '今天已經做得夠多了，先好好休息。';
  String get nightlyClosingBodyEncourage =>
      isEnglish ? 'You showed up today. That matters.' : '今天你願意出現，就已經很重要了。';
  String get nightlyClosingBodyShort => isEnglish ? 'Rest well.' : '晚安，好好休息。';
  String get weeklyClosingGentle =>
      isEnglish ? 'Slow and steady is enough.' : '慢慢走就很好了。';
  String get weeklyClosingEncourage =>
      isEnglish ? 'You kept going this week.' : '這一週你一直在努力。';
  String get weeklyClosingShort => isEnglish ? 'Keep it light.' : '保持輕盈就好。';
  String get responseSavedGentle => isEnglish ? 'I have noted it.' : '我已經記住了。';
  String get responseSavedEncourage =>
      isEnglish ? 'Well done. I am with you.' : '做得好，我陪你。';
  String get responseSavedShort => isEnglish ? 'Noted.' : '已記錄。';
  String get responseTaskDoneGentle =>
      isEnglish ? 'You did it, softly.' : '你完成了，真好。';
  String get responseTaskDoneEncourage =>
      isEnglish ? 'Great job. Keep going.' : '做得很好，繼續加油。';
  String get responseTaskDoneShort => isEnglish ? 'Done.' : '完成。';
  String get companionHeader => isEnglish ? 'Your companion notes' : '陪伴紀錄';
  String get companionEmpty => isEnglish ? 'No sessions yet.' : '目前沒有陪伴紀錄';
  String get companionModeListen => isEnglish ? 'I want to be heard' : '我想被傾聽';
  String get companionModeCalm => isEnglish ? 'Quiet reset' : '我想安靜整理一下';
  String get companionModeCompanion =>
      isEnglish ? '10-minute companion' : '陪伴 10 分鐘';
  String get companionReplyGentle =>
      isEnglish ? 'Thank you for sharing. I am here.' : '謝謝你願意說，我在。';
  String get companionReplyEncourage =>
      isEnglish ? 'You did well to say it.' : '你願意說出來很不容易。';
  String get companionReplyShort => isEnglish ? 'Received.' : '收到。';
  String weeklySummary(double avg, int max, int min) =>
      isEnglish
          ? 'Weekly average ${avg.toStringAsFixed(1)}, high $max, low $min.'
          : '本週平均心情 ${avg.toStringAsFixed(1)}，最高 $max，最低 $min。';

  String get moodScaleHigh => isEnglish ? 'High' : '高';
  String get moodScaleMid => isEnglish ? 'Mid' : '中';
  String get moodScaleLow => isEnglish ? 'Low' : '低';

  String get diaryTitle => isEnglish ? 'Mindfulness' : '正念引導';
  String get weeklyDistribution =>
      isEnglish ? 'Weekly Mood Distribution' : '本週心情分佈';
  String get moodSelect => isEnglish ? 'Mood' : '心情選擇';
  String get diaryTemplate => isEnglish ? 'Template' : '日記模板';
  String get mindfulness => isEnglish ? 'Mindfulness' : '正念引導';
  String get noGuide => isEnglish ? 'No guides yet' : '尚無引導內容';
  String get diaryContent => isEnglish ? 'Diary Content' : '日記內容';
  String get diaryHint =>
      isEnglish ? 'Would you like to write how you feel?' : '你願意寫下現在的感覺嗎？';
  String get saveDiary => isEnglish ? 'Save Diary' : '保存日記';
  String get diarySaved => isEnglish ? 'Diary saved' : '日記已保存';
  String weeklyMoodSummary(String mood, int count) =>
      isEnglish
          ? 'Most frequent mood: "$mood" ($count).'
          : '本週最常出現的心情是「$mood」（$count 次）。';

  String get companionTitle => isEnglish ? 'Companion' : '陪伴助手';
  String get companionInputHint =>
      isEnglish ? 'Share how you feel...' : '輸入你的心情...';
  String get companionSaved => isEnglish ? 'Session saved' : '已記錄陪伴';

  String get sosTitle => isEnglish ? 'SOS' : 'SOS 求助';
  String get sosContact => isEnglish ? 'Emergency Contact' : '求助聯絡人';
  String get sosName => isEnglish ? 'Name' : '姓名';
  String get sosPhone => isEnglish ? 'Phone' : '電話';
  String get sosMessage => isEnglish ? 'Message' : '求助訊息';
  String get sosDefaultMessage =>
      isEnglish
          ? 'I need help right now. Can you stay with me?'
          : '我現在需要幫助，可以陪我一下嗎？';
  String get saveContact => isEnglish ? 'Save Contact' : '保存聯絡人';
  String get contactSaved => isEnglish ? 'Contact saved' : '已保存聯絡人';
  String get needHelp => isEnglish ? 'I need help' : '我需要幫助';
  String get sendHelp => isEnglish ? 'Send Help' : '一鍵求助';
  String get helpSent => isEnglish ? 'Help message sent (demo)' : '已送出求助訊息（示意）';

  String get cropPhotoTitle => isEnglish ? 'Crop Photo' : '裁切照片';
  String get cropCancel => isEnglish ? 'Cancel' : '取消';
  String get cropApply => isEnglish ? 'Crop' : '裁切';

  String mindfulnessDuration(String duration) =>
      isEnglish ? 'Duration: $duration' : '時長：$duration';

  String languageOptionLabel(String code) {
    if (code == 'zh-TW') return isEnglish ? 'Traditional Chinese' : '繁體中文';
    if (code == 'en') return 'English';
    return code;
  }

  String toneOptionLabel(String tone) {
    if (isEnglish) {
      switch (tone) {
        case 'gentle':
          return 'Gentle';
        case 'encourage':
          return 'Encouraging';
        case 'short':
          return 'Short';
        default:
          return tone;
      }
    }
    switch (tone) {
      case 'gentle':
        return '溫柔';
      case 'encourage':
        return '鼓勵';
      case 'short':
        return '簡短';
      default:
        return tone;
    }
  }

  String applyToneToGreeting(String greeting, String tone) {
    switch (tone) {
      case 'encourage':
        return '$greeting$toneEncourageGreetingTail';
      case 'gentle':
        return '$greeting$toneGentleGreetingTail';
      default:
        return greeting;
    }
  }

  String applyToneToDirection(String direction, String tone) {
    switch (tone) {
      case 'short':
        return toneShortDirection;
      case 'encourage':
        return '$direction$toneEncourageDirectionTail';
      default:
        return direction;
    }
  }

  String applyToneToAffirmation(String affirmation, String tone) {
    switch (tone) {
      case 'encourage':
        return '$toneEncourageAffirmationPrefix$affirmation';
      case 'gentle':
        return '$toneGentleAffirmationPrefix$affirmation';
      default:
        return affirmation;
    }
  }

  List<String> softInterventionSuggestions(String tone) {
    if (isEnglish) {
      switch (tone) {
        case 'short':
          return ['Take 3 breaths.', 'Pick one tiny task.', 'Write one line.'];
        case 'encourage':
          return [
            'Take 3 breaths. You’re doing great.',
            'Pick one tiny task. I’m with you.',
            'Write one line. That is enough.',
          ];
        default:
          return [
            'Take 3 gentle breaths.',
            'Pick one tiny task.',
            'Write one kind line to yourself.',
          ];
      }
    }
    switch (tone) {
      case 'short':
        return ['先深呼吸 3 次。', '挑一個小任務。', '寫下一句話。'];
      case 'encourage':
        return ['先深呼吸 3 次，你做得到。', '挑一個小任務，我陪你。', '寫下一句話，這樣就很好了。'];
      default:
        return ['先深呼吸 3 次。', '挑一個小任務。', '寫下一句對自己的溫柔話。'];
    }
  }

  String nightlyClosingBody(String tone) {
    if (isEnglish) {
      switch (tone) {
        case 'encourage':
          return _pickVariant(_nightlyEncourageEn);
        case 'short':
          return _pickVariant(_nightlyShortEn);
        default:
          return _pickVariant(_nightlyGentleEn);
      }
    }
    switch (tone) {
      case 'encourage':
        return _pickVariant(_nightlyEncourageZh);
      case 'short':
        return _pickVariant(_nightlyShortZh);
      default:
        return _pickVariant(_nightlyGentleZh);
    }
  }

  String weeklyClosingLine(String tone) {
    switch (tone) {
      case 'encourage':
        return weeklyClosingEncourage;
      case 'short':
        return weeklyClosingShort;
      default:
        return weeklyClosingGentle;
    }
  }

  String responseSavedLine(String tone) {
    if (isEnglish) {
      switch (tone) {
        case 'encourage':
          return _pickVariant(_responseEncourageEn);
        case 'short':
          return _pickVariant(_responseShortEn);
        default:
          return _pickVariant(_responseGentleEn);
      }
    }
    switch (tone) {
      case 'encourage':
        return _pickVariant(_responseEncourageZh);
      case 'short':
        return _pickVariant(_responseShortZh);
      default:
        return _pickVariant(_responseGentleZh);
    }
  }

  String responseTaskDoneLine(String tone) {
    switch (tone) {
      case 'encourage':
        return responseTaskDoneEncourage;
      case 'short':
        return responseTaskDoneShort;
      default:
        return responseTaskDoneGentle;
    }
  }

  String companionReplyLine(String tone) {
    switch (tone) {
      case 'encourage':
        return companionReplyEncourage;
      case 'short':
        return companionReplyShort;
      default:
        return companionReplyGentle;
    }
  }

  int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays;
  }

  String _pickVariant(List<String> lines) {
    if (lines.isEmpty) return '';
    final index = _dayOfYear(DateTime.now()) % lines.length;
    return lines[index];
  }

  static const List<String> _responseGentleZh = [
    '今天辛苦了，你已經很努力。',
    '慢慢來就好，我在。',
    '你願意走到這裡，真的很不容易。',
    '把步伐放小，你也在前進。',
    '今天的你已經做得很好。',
    '先照顧自己一下，值得的。',
    '就算只有一點點，也很珍貴。',
    '你不需要完美，夠好了。',
    '謝謝你願意陪自己一會。',
    '此刻你還在努力，這很重要。',
    '辛苦了，先把自己放在前面。',
    '可以慢慢來，我會等你。',
    '你的感受很重要。',
    '今天的步伐也算數。',
    '你已經在照顧自己了。',
    '把心放鬆一點也很好。',
    '你值得被溫柔對待。',
    '這一步很不容易，我知道。',
    '能停下來照顧自己，就是進步。',
    '你願意記錄，很珍貴。',
    '此刻先陪陪自己。',
    '你已經盡力了。',
    '今天的你，已經很了不起。',
    '把自己抱緊一點。',
    '慢慢走，也是在前進。',
    '你的心正在變柔軟。',
    '你有好好活著，謝謝你。',
    '先休息一下也沒關係。',
    '你不需要急。',
    '我會在這裡。',
  ];

  static const List<String> _responseEncourageZh = [
    '你做得很好，我相信你。',
    '只要到這裡就很棒了。',
    '你正在一步步前進。',
    '今天也撐過來了，真不容易。',
    '你的努力我看見了。',
    '把這一步走好就夠了。',
    '你可以的，我陪你。',
    '再小的進步都算數。',
    '你很勇敢，繼續走。',
    '你正在累積力量。',
    '你已經做到今天最難的部分。',
    '繼續一步一步，就會到。',
    '你比想像中更堅強。',
    '這一步很棒，繼續。',
    '你正在變得更好。',
    '把力氣留給下一步。',
    '今天也有前進。',
    '你的努力會被看見。',
    '你正在為自己加油。',
    '你值得被肯定。',
    '再走一點點就好。',
    '我相信你做得到。',
    '你正在累積勇氣。',
    '你可以相信自己。',
    '保持節奏就好。',
    '你已經很勇敢。',
    '你不是孤單的。',
    '這一步算數，下一步也會。',
    '你有把自己撐住。',
    '你正在變強。',
  ];

  static const List<String> _responseShortZh = [
    '已記錄。',
    '收到。',
    '我記下了。',
    '已保存。',
    '知道了。',
    '好。',
    '記住了。',
    '完成紀錄。',
    '已完成。',
    '收到你的心意。',
    '已收到。',
    '記錄中。',
    'OK。',
    '完成。',
    '明白。',
    '我收到。',
    '已存。',
    '我在。',
    '好喔。',
    '已看見。',
    '備註完成。',
    '完成了。',
    '已建立。',
    '收到訊息。',
    'OK，記下。',
    '已更新。',
    '已保存完成。',
    '完成記錄。',
    '已記。',
    '已收到訊息。',
  ];

  static const List<String> _responseGentleEn = [
    'You made it through today. That is enough.',
    'Take it slow. I am here.',
    'You showed up, and that matters.',
    'Small steps still count.',
    'You did well today.',
    'Be kind to yourself.',
    'Even a little is meaningful.',
    'You do not have to be perfect.',
    'Thank you for staying with yourself.',
    'Your effort matters.',
    'You are doing your best.',
    'It is okay to slow down.',
    'Your feelings are valid.',
    'This step counts.',
    'Thank you for being here.',
    'You deserve gentleness.',
    'Even a little is progress.',
    'You are taking care of yourself.',
    'I see you.',
    'It is okay to rest.',
    'You do not have to rush.',
    'You are enough today.',
    'You are learning to be kind to yourself.',
    'Thank you for staying with it.',
    'You are doing something hard.',
    'Hold yourself softly.',
    'I am here with you.',
    'Small steps are still steps.',
    'Your effort is real.',
    'You are allowed to take your time.',
  ];

  static const List<String> _responseEncourageEn = [
    'You did great. I believe in you.',
    'Getting this far is already good.',
    'You are moving forward.',
    'You made it through today.',
    'I see your effort.',
    'This step is enough.',
    'You have got this.',
    'Every small win counts.',
    'You are brave. Keep going.',
    'You are building strength.',
    'You are stronger than you think.',
    'One more small step is great.',
    'You are making progress.',
    'Keep this pace, it works.',
    'You can do this.',
    'Your courage shows.',
    'You are not alone.',
    'Your effort will pay off.',
    'You are building momentum.',
    'This is a good step.',
    'You have got this, one step at a time.',
    'I believe you can.',
    'You are getting better at this.',
    'You are doing something brave.',
    'Keep going, I am with you.',
    'You are showing up.',
    'This is enough for now.',
    'You are moving forward.',
    'You are doing the hard thing.',
    'You are stronger each day.',
  ];

  static const List<String> _responseShortEn = [
    'Noted.',
    'Saved.',
    'Got it.',
    'Recorded.',
    'OK.',
    'Done.',
    'Captured.',
    'Logged.',
    'Received.',
    'All set.',
    'Seen.',
    'Okay.',
    'Stored.',
    'Filed.',
    'Marked.',
    'Set.',
    'Written.',
    'Captured it.',
    'Thanks.',
    'Alright.',
    'Accepted.',
    'Acknowledged.',
    'In record.',
    'Counted.',
    'Kept.',
    'Saved it.',
    'Done now.',
    'All good.',
    'Noted it.',
    'Recorded it.',
  ];

  static const List<String> _nightlyGentleZh = [
    '今天已經夠了，先好好休息。',
    '辛苦了，讓自己慢慢放鬆。',
    '你做得很好，晚安。',
    '把今天放下，明天再說。',
    '現在可以安心休息了。',
    '謝謝你今天的努力。',
    '你已經走到這裡，足夠了。',
    '身體和心都需要歇一下。',
    '今晚好好睡，明天再出發。',
    '慢慢來，我們明天見。',
    '今晚就先這樣吧。',
    '把心安放好。',
    '你已經很努力了，晚安。',
    '今晚好好睡。',
    '把今天交給夜晚。',
    '讓身體慢慢放鬆。',
    '明天再出發也可以。',
    '現在可以歇一會兒。',
    '感謝你今天的存在。',
    '休息也是前進的一部分。',
    '把自己輕輕抱住。',
    '今晚只要放鬆。',
    '辛苦了一天，安眠。',
    '今天到此為止。',
    '把思緒放下。',
    '夜晚會照顧你。',
    '好好睡一覺。',
    '明天會更清晰。',
    '給自己一點溫柔。',
    '慢慢呼吸，晚安。',
  ];

  static const List<String> _nightlyEncourageZh = [
    '你撐過今天了，真棒。',
    '今天的努力很重要，晚安。',
    '你很勇敢，現在可以休息。',
    '再小的堅持都很有力量。',
    '你做得很好，明天再加油。',
    '今天已經很好了。',
    '你正在變得更強。',
    '你值得好好睡一覺。',
    '今晚先停一下，明天繼續。',
    '你已經走得很遠了。',
    '你今天很棒，值得休息。',
    '辛苦了，明天再向前。',
    '你已經跨過一個坎。',
    '每一步都算數，晚安。',
    '你正在變得更勇敢。',
    '今天的你很了不起。',
    '你做得很好，給自己掌聲。',
    '休息後會更有力量。',
    '今晚先收工，明天再戰。',
    '你已經贏過自己。',
    '你正在學會照顧自己。',
    '為自己點個讚。',
    '你持續前進，真棒。',
    '這就是成長。',
    '明天再加油。',
    '你很堅持。',
    '你值得被好好對待。',
    '你的努力會被記得。',
    '現在安心睡。',
    '你很棒，晚安。',
  ];

  static const List<String> _nightlyShortZh = [
    '晚安。',
    '好好休息。',
    '今天到這裡。',
    '辛苦了。',
    '睡吧。',
    '收工。',
    '先休息。',
    '到此為止。',
    '明天見。',
    '晚安，好夢。',
    '睡了。',
    '收工囉。',
    '先到這。',
    '先休息一下。',
    '夜安。',
    '晚安呀。',
    '好好睡。',
    '睡個好覺。',
    '放鬆吧。',
    '今天收尾。',
    '明天再說。',
    '休息一下。',
    '先停下。',
    '到這裡。',
    '安心睡。',
    '晚安喔。',
    '晚安，拜拜。',
    '晚安，明天見。',
    '夜裡安好。',
    '晚安，休息。',
  ];

  static const List<String> _nightlyGentleEn = [
    'You did enough today. Rest now.',
    'You worked hard. Let yourself unwind.',
    'You did well today. Good night.',
    'Leave today here. Tomorrow is another day.',
    'You can rest now.',
    'Thank you for your effort today.',
    'You made it this far. That is enough.',
    'Let your body and mind rest.',
    'Sleep well. We will try again tomorrow.',
    'Take it slow. See you tomorrow.',
    'Let tonight hold you.',
    'You can let go now.',
    'Rest is part of the work.',
    'You have done enough for today.',
    'It is okay to pause.',
    'Be gentle with yourself tonight.',
    'You can soften now.',
    'Thank you for making it to night.',
    'Allow yourself to rest.',
    'The day can end here.',
    'You can set it down now.',
    'Breathe out and rest.',
    'You are safe to sleep.',
    'Let the night be kind.',
    'You did what you could.',
    'Rest your mind and body.',
    'Sleep and reset.',
    'See you when morning comes.',
    'Tonight is for rest.',
    'Good night. Be easy on yourself.',
  ];

  static const List<String> _nightlyEncourageEn = [
    'You made it through today. Well done.',
    'Your effort matters. Good night.',
    'You are brave. Now rest.',
    'Every bit of persistence counts.',
    'You did great. We will go again tomorrow.',
    'Today was good enough.',
    'You are getting stronger.',
    'You deserve good rest.',
    'Pause tonight. Continue tomorrow.',
    'You have come a long way.',
    'You showed up today. That is big.',
    'You did something hard. Rest now.',
    'You kept going. Good night.',
    'You are building strength. Sleep well.',
    'You earned this rest.',
    'You are doing better than you think.',
    'You stayed with it. Well done.',
    'Tomorrow is another chance.',
    'Your courage showed today.',
    'You are moving forward. Rest.',
    'You pushed through today.',
    'You did your part. Now sleep.',
    'You are making progress.',
    'You held on. That matters.',
    'You kept your promise to yourself.',
    'You can be proud tonight.',
    'You are growing.',
    'You have got this. Sleep now.',
    'Your effort counts. Rest.',
    'You did enough. Good night.',
  ];

  static const List<String> _nightlyShortEn = [
    'Good night.',
    'Rest well.',
    'That is it for today.',
    'Sleep now.',
    'Done for today.',
    'Pause.',
    'See you tomorrow.',
    'Night.',
    'Take a rest.',
    'Good sleep.',
    'Sleep.',
    'All done.',
    'Time to rest.',
    'Nighty.',
    'Lights out.',
    'See you.',
    'Rest.',
    'Good night now.',
    'Tomorrow.',
    'Sleep well now.',
    'Shut down.',
    'All set.',
    'Wrap it up.',
    'Off to bed.',
    'Quiet time.',
    'End of day.',
    'Resting now.',
    'Take it easy.',
    'Sweet dreams.',
    'Good night, friend.',
  ];

  String companionModeLabel(String mode) {
    switch (mode) {
      case 'listen':
        return companionModeListen;
      case 'calm':
        return companionModeCalm;
      case 'companion':
        return companionModeCompanion;
      default:
        return mode;
    }
  }

  String preferredModeLabel(String mode) {
    if (isEnglish) {
      switch (mode) {
        case 'text':
          return 'Text';
        case 'voice':
          return 'Voice';
        case 'task':
          return 'Tasks';
        default:
          return mode;
      }
    }
    switch (mode) {
      case 'text':
        return '文字';
      case 'voice':
        return '語音';
      case 'task':
        return '任務';
      default:
        return mode;
    }
  }

  String triggerLabel(String trigger) {
    if (isEnglish) {
      switch (trigger) {
        case 'lonely':
          return 'Lonely';
        case 'stress':
          return 'Stress';
        case 'body':
          return 'Body';
        default:
          return trigger;
      }
    }
    switch (trigger) {
      case 'lonely':
        return '孤單';
      case 'stress':
        return '壓力';
      case 'body':
        return '身體不適';
      default:
        return trigger;
    }
  }

  String moodLabel(String tag) {
    if (isEnglish) {
      switch (tag) {
        case 'calm':
          return 'Calm';
        case 'sad':
          return 'Sad';
        case 'anxious':
          return 'Anxious';
        default:
          return tag;
      }
    }
    switch (tag) {
      case 'calm':
        return '平靜';
      case 'sad':
        return '低落';
      case 'anxious':
        return '焦慮';
      default:
        return tag;
    }
  }

  String templateLabel(String tag) {
    if (isEnglish) {
      switch (tag) {
        case 'gratitude':
          return 'Gratitude';
        case 'release':
          return 'Release';
        case 'hope':
          return 'Hope';
        default:
          return tag;
      }
    }
    switch (tag) {
      case 'gratitude':
        return '感謝';
      case 'release':
        return '放下';
      case 'hope':
        return '希望';
      default:
        return tag;
    }
  }
}
