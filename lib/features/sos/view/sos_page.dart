import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sos_contact.dart';
import '../../../data/repositories/sos_repository.dart';
import '../../../common/app_strings.dart';
import '../../../common/locale_provider.dart';

class SOSPage extends ConsumerStatefulWidget {
  const SOSPage({super.key});

  @override
  ConsumerState<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends ConsumerState<SOSPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(ref.watch(localeProvider));
    if (_messageController.text.isEmpty) {
      _messageController.text = strings.sosDefaultMessage;
    }
    return Scaffold(
      appBar: AppBar(title: Text(strings.sosTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(strings.sosContact, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: strings.sosName),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: strings.sosPhone),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(labelText: strings.sosMessage),
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
                SnackBar(content: Text(strings.contactSaved)),
              );
            },
            child: Text(strings.saveContact),
          ),
          const SizedBox(height: 24),
          Text(strings.needHelp, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.helpSent)),
              );
            },
            child: Text(strings.sendHelp),
          ),
        ],
      ),
    );
  }
}
