import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final String hex;
  final Color color;

  const AppTheme({required this.name, required this.hex, required this.color});
}

const List<AppTheme> kAppThemes = [
  AppTheme(name: '柔藍', hex: '#75C9E0', color: Color(0xFF75C9E0)),
  AppTheme(name: '柔綠', hex: '#B5EAD7', color: Color(0xFFB5EAD7)),
  AppTheme(name: '柔粉', hex: '#FEC8D8', color: Color(0xFFFEC8D8)),
  AppTheme(name: '柔紫', hex: '#D7BDE2', color: Color(0xFFD7BDE2)),
  AppTheme(name: '卡其', hex: '#D8CAB8', color: Color(0xFFD8CAB8)),
]; 