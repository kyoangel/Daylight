import 'package:flutter/material.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS 求助')),
      body: ListView(
        children: const [
          ListTile(title: Text('我需要幫助')),
          ListTile(title: Text('求助聯絡人')),
          ListTile(title: Text('寫給情緒的一封信')),
        ],
      ),
    );
  }
} 