import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('個人')), 
      body: ListView(
        children: const [
          ListTile(title: Text('暱稱/資料')), 
          ListTile(title: Text('提醒設定')), 
        ],
      ),
    );
  }
} 