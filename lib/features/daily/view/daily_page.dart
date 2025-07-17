import 'package:flutter/material.dart';

class DailyPage extends StatelessWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日常節奏')),
      body: ListView(
        children: const [
          ListTile(title: Text('早晨問候')),
          ListTile(title: Text('今日目標設定')),
          ListTile(title: Text('晚安反思')),
        ],
      ),
    );
  }
} 