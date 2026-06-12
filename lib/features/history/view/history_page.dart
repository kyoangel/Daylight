import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/daily_entry.dart';
import '../../../features/daily/viewmodel/daily_viewmodel.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(ref.watch(localeProvider));
    final entries = ref.watch(dailyViewModelProvider);
    final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: Text(strings.historyTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MoodTrendSection(entries: sorted, strings: strings),
          Expanded(
            child: sorted.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        strings.historyEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.5),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _HistoryEntryCard(
                      entry: sorted[i],
                      strings: strings,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  const _HistoryEntryCard({required this.entry, required this.strings});

  final DailyEntry entry;
  final AppStrings strings;

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final diff = todayDate.difference(entryDate).inDays;
    if (diff == 0) return strings.historyToday;
    if (diff == 1) return strings.historyYesterday;
    if (strings.isEnglish) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
    return '${date.month}月${date.day}日';
  }

  Color _chipColor(String id) {
    const colors = <String, Color>{
      'em_happy':     Color(0x30FFD166),
      'em_grateful':  Color(0x3055EBBF),
      'em_fulfilled': Color(0x3074B9FF),
      'em_excited':   Color(0x30FF9F43),
      'em_blissful':  Color(0x30C8A2E8),
      'em_anxious':   Color(0x30FFB347),
      'em_tired':     Color(0x30A8B5C8),
      'em_lonely':    Color(0x307B9BB4),
      'em_irritable': Color(0x30E07B7B),
      'em_sad':       Color(0x308B9DC3),
      // legacy
      'em_calm':      Color(0x307EC8A0),
      'em_okay':      Color(0x30A5C8A5),
      'em_numb':      Color(0x30B0B0B0),
    };
    return colors[id] ?? Colors.grey.withOpacity(0.15);
  }

  String _chipLabel(String id) {
    if (strings.isEnglish) {
      const en = <String, String>{
        'em_happy': 'Happy', 'em_grateful': 'Grateful', 'em_fulfilled': 'Fulfilled',
        'em_excited': 'Excited', 'em_blissful': 'Blissful',
        'em_anxious': 'Anxious', 'em_tired': 'Tired', 'em_lonely': 'Lonely',
        'em_irritable': 'Irritable', 'em_sad': 'Sad',
        'em_calm': 'Calm', 'em_okay': 'Okay', 'em_numb': 'Numb',
      };
      return en[id] ?? id;
    }
    const zh = <String, String>{
      'em_happy': '開心', 'em_grateful': '感恩', 'em_fulfilled': '充實',
      'em_excited': '興奮', 'em_blissful': '幸福',
      'em_anxious': '焦慮', 'em_tired': '疲憊', 'em_lonely': '孤獨',
      'em_irritable': '煩躁', 'em_sad': '難過',
      'em_calm': '平靜', 'em_okay': '還好', 'em_numb': '麻木',
    };
    return zh[id] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(entry.date),
              style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            if (entry.emotionLabels.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: entry.emotionLabels.map((id) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _chipColor(id),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_chipLabel(id), style: const TextStyle(fontSize: 13)),
                )).toList(),
              ),
              if (entry.emotionIntensity != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (i) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < (entry.emotionIntensity ?? 0)
                          ? Colors.blueGrey.shade400
                          : Colors.grey.shade200,
                    ),
                  )),
                ),
              ],
            ] else
              Text(
                '${strings.historyMoodFallback} ${entry.moodScore} / 10',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),

            if (entry.eventNote != null && entry.eventNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '「${entry.eventNote}」',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Mood Trend Section ───────────────────────────────────────────────────────

class _MoodTrendSection extends StatefulWidget {
  const _MoodTrendSection({required this.entries, required this.strings});
  final List<DailyEntry> entries;
  final AppStrings strings;

  @override
  State<_MoodTrendSection> createState() => _MoodTrendSectionState();
}

class _MoodTrendSectionState extends State<_MoodTrendSection> {
  int _tab = 0; // 0=daily, 1=weekly, 2=monthly

  DailyEntry? _entryForDay(DateTime day) {
    for (final e in widget.entries) {
      if (e.date.year == day.year && e.date.month == day.month && e.date.day == day.day) {
        return e;
      }
    }
    return null;
  }

  List<_BarData> _dailyBars() {
    final today = DateTime.now();
    final bars = <_BarData>[];
    for (int i = 13; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final entry = _entryForDay(day);
      final score = entry?.derivedMoodScore ?? 0;
      final label = i == 0
          ? (widget.strings.isEnglish ? 'Today' : '今')
          : '${day.month}/${day.day}';
      bars.add(_BarData(score: score, label: label));
    }
    return bars;
  }

  List<_BarData> _weeklyBars() {
    final today = DateTime.now();
    final bars = <_BarData>[];
    for (int w = 7; w >= 0; w--) {
      final endDay = DateTime(today.year, today.month, today.day).subtract(Duration(days: w * 7));
      final startDay = endDay.subtract(const Duration(days: 6));
      final weekEntries = widget.entries.where((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return !d.isBefore(startDay) && !d.isAfter(endDay);
      }).toList();
      final avgScore = weekEntries.isEmpty
          ? 0
          : (weekEntries.map((e) => e.derivedMoodScore).reduce((a, b) => a + b) / weekEntries.length).round();
      final label = w == 0
          ? (widget.strings.isEnglish ? 'This\nwk' : '本週')
          : '${startDay.month}/${startDay.day}';
      bars.add(_BarData(score: avgScore, label: label));
    }
    return bars;
  }

  List<_BarData> _monthlyBars() {
    final today = DateTime.now();
    final bars = <_BarData>[];
    for (int m = 5; m >= 0; m--) {
      int year = today.year;
      int month = today.month - m;
      while (month <= 0) {
        month += 12;
        year--;
      }
      final monthEntries = widget.entries
          .where((e) => e.date.year == year && e.date.month == month)
          .toList();
      final avgScore = monthEntries.isEmpty
          ? 0
          : (monthEntries.map((e) => e.derivedMoodScore).reduce((a, b) => a + b) / monthEntries.length).round();
      final label = widget.strings.isEnglish
          ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1]
          : '$month月';
      bars.add(_BarData(score: avgScore, label: label));
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      widget.strings.trendTabDaily,
      widget.strings.trendTabWeekly,
      widget.strings.trendTabMonthly,
    ];
    final bars = _tab == 0 ? _dailyBars() : _tab == 1 ? _weeklyBars() : _monthlyBars();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.strings.trendSectionTitle,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(tabs.length, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _tab == i ? Colors.blueGrey.shade700 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: _tab == i ? Colors.white : Colors.black54,
                      fontWeight: _tab == i ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 10),
          _BarChart(bars: bars),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _BarData {
  const _BarData({required this.score, required this.label});
  final int score;
  final String label;
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.bars});
  final List<_BarData> bars;

  static const double halfHeight = 56.0;
  static const double barWidth = 26.0;
  static const double labelHeight = 20.0;

  Color _barColor(int score) {
    if (score == 0) return Colors.grey.shade200;
    if (score > 0) {
      if (score >= 4) return Colors.teal.shade500;
      if (score >= 2) return Colors.teal.shade300;
      return Colors.teal.shade200;
    }
    if (score <= -4) return Colors.red.shade400;
    if (score <= -2) return Colors.red.shade300;
    return Colors.red.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: halfHeight * 2 + 1 + 4 + labelHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bars.map((bar) {
            final absH = halfHeight * bar.score.abs() / 5;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                children: [
                  // Positive area — bar grows upward from center
                  SizedBox(
                    height: halfHeight,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: bar.score > 0
                          ? Container(
                              width: barWidth,
                              height: absH,
                              decoration: BoxDecoration(
                                color: _barColor(bar.score),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // Center baseline
                  Container(height: 1, width: barWidth, color: Colors.grey.shade300),
                  // Negative area — bar grows downward from center
                  SizedBox(
                    height: halfHeight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: bar.score < 0
                          ? Container(
                              width: barWidth,
                              height: absH,
                              decoration: BoxDecoration(
                                color: _barColor(bar.score),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: barWidth,
                    height: labelHeight,
                    child: Text(
                      bar.label,
                      style: const TextStyle(fontSize: 9, color: Colors.black45),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
