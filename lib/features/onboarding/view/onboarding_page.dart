import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('歡迎')), 
      body: PageView(
        children: const [
          Center(child: Text('你不是一個人')),
          Center(child: Text('我們陪你走過一天')),
          Center(child: Text('你的每一小步都值得')),
        ],
      ),
    );
  }
} 