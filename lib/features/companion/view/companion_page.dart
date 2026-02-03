import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/companion_session.dart';
import '../../../data/repositories/companion_repository.dart';

class CompanionPage extends ConsumerStatefulWidget {
  const CompanionPage({super.key});

  @override
  ConsumerState<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends ConsumerState<CompanionPage> {
  final TextEditingController _inputController = TextEditingController();
  String _selectedMode = 'listen';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('陪伴助手')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: _selectedMode,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'listen', child: Text('我想被傾聽')),
                DropdownMenuItem(value: 'calm', child: Text('我想安靜整理一下')),
                DropdownMenuItem(value: 'companion', child: Text('陪伴 10 分鐘')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedMode = value;
                });
              },
            ),
          ),
          Expanded(child: ListView()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(hintText: '輸入你的心情...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final repo = CompanionRepository();
                    final now = DateTime.now();
                    final session = CompanionSession(
                      id: 'comp_${now.millisecondsSinceEpoch}',
                      mode: _selectedMode,
                      startAt: now,
                      endAt: now.add(const Duration(minutes: 10)),
                      summary: _inputController.text.trim(),
                    );
                    await repo.add(session);
                    if (!mounted) return;
                    _inputController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已記錄陪伴')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
