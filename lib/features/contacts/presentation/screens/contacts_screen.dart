// lib/features/contacts/presentation/screens/contacts_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/avatar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<Map<String, String>> _contacts = [
    {
      'id': 'user_sarah',
      'name': 'Sarah Jenkins',
      'email': 'sarah@tunemate.com',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
      'status': 'Listening to Lo-Fi Beats 🎧',
    },
    {
      'id': 'user_marcus',
      'name': 'Marcus Aurelius',
      'email': 'marcus@tunemate.com',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150',
      'status': 'Gym time 🏋️‍♂️',
    },
    {
      'id': 'user_clara',
      'name': 'Clara Oswald',
      'email': 'clara@tunemate.com',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150',
      'status': 'Traveling the cosmos 🌌',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add contact dialog coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            leading: Avatar(
              displayName: contact['name']!,
              imageUrl: contact['avatar'],
              size: 44,
            ),
            title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(contact['status']!),
            onTap: () {
              context.push('/chat/conv_mock_$index');
            },
          );
        },
      ),
    );
  }
}
