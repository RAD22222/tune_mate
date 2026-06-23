// lib/features/conversations/presentation/screens/new_conversation_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/avatar.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final List<Map<String, String>> _mockContacts = [
    {
      'id': 'user_sarah',
      'name': 'Sarah Jenkins',
      'email': 'sarah@tunemate.com',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
    },
    {
      'id': 'user_marcus',
      'name': 'Marcus Aurelius',
      'email': 'marcus@tunemate.com',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150',
    },
    {
      'id': 'user_clara',
      'name': 'Clara Oswald',
      'email': 'clara@tunemate.com',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.group_outlined, color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('New Group', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              // TODO: Implement group creation UI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group creation flow coming soon!')),
              );
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person_add_alt_1_outlined, color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => context.push('/contacts'),
          ),
          const Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: Text(
              'Contacts',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ..._mockContacts.map((contact) {
            return ListTile(
              leading: Avatar(
                displayName: contact['name']!,
                imageUrl: contact['avatar'],
                size: 40,
              ),
              title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(contact['email']!),
              onTap: () {
                // Return a mock chat ID matching the contact index
                final index = _mockContacts.indexWhere((c) => c['id'] == contact['id']);
                context.replace('/chat/conv_mock_$index');
              },
            );
          }),
        ],
      ),
    );
  }
}
