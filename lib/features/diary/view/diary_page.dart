import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('情緒日記')),
      body: ListView(
        children: const [
          ListTile(title: Text('心情選擇')),
          ListTile(title: Text('日記輸入')),
          ListTile(title: Text('每週回顧')),
        ],
      ),
    );
  }
} 