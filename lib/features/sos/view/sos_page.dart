import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sos_contact.dart';
import '../../../data/repositories/sos_repository.dart';

class SOSPage extends ConsumerStatefulWidget {
  const SOSPage({super.key});

  @override
  ConsumerState<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends ConsumerState<SOSPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(
    text: '我現在需要幫助，可以陪我一下嗎？',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS 求助')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('求助聯絡人', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '姓名'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: '電話'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '求助訊息'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final contact = SOSContact(
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                messageTemplate: _messageController.text.trim(),
              );
              final repo = SOSRepository();
              await repo.saveAll([contact]);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已保存聯絡人')),
              );
            },
            child: const Text('保存聯絡人'),
          ),
          const SizedBox(height: 24),
          const Text('我需要幫助', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已送出求助訊息（示意）')),
              );
            },
            child: const Text('一鍵求助'),
          ),
        ],
      ),
    );
  }
}
