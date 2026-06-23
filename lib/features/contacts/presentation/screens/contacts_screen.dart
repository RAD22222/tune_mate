// FILE: lib/features/contacts/presentation/screens/contacts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../services/supabase/contact_service.dart';
import '../../../../services/supabase/supabase_service.dart';
import '../providers/contacts_provider.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _emailSearchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _searchResult;
  String? _searchError;

  @override
  void dispose() {
    _emailSearchController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    setState(() {
      _searchResult = null;
      _searchError = null;
      _emailSearchController.clear();
      _isSearching = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> performSearch() async {
              final email = _emailSearchController.text.trim();
              if (email.isEmpty) return;

              setDialogState(() {
                _isSearching = true;
                _searchResult = null;
                _searchError = null;
              });

              try {
                final result = await ContactService().searchUserByEmail(email);
                setDialogState(() {
                  _isSearching = false;
                  if (result == null) {
                    _searchError = 'No user found with this email';
                  } else {
                    _searchResult = result;
                  }
                });
              } catch (e) {
                setDialogState(() {
                  _isSearching = false;
                  _searchError = 'Error searching user: $e';
                });
              }
            }

            Future<void> sendRequest(String targetUserId) async {
              setDialogState(() {
                _isSearching = true;
              });
              try {
                await ContactService().sendConnectionRequest(targetUserId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connection request sent!')),
                  );
                }
              } catch (e) {
                setDialogState(() {
                  _isSearching = false;
                  _searchError = 'Failed to send request: $e';
                });
              }
            }

            return AlertDialog(
              title: const Text('Add Contact'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Search others by email to send a connection request.'),
                    const SizedBox(height: AppSizes.p16),
                    TextField(
                      controller: _emailSearchController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: performSearch,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(AppSizes.r12)),
                        ),
                      ),
                      onSubmitted: (_) => performSearch(),
                    ),
                    const SizedBox(height: AppSizes.p24),
                    if (_isSearching)
                      const CircularProgressIndicator()
                    else if (_searchError != null)
                      Text(_searchError!, style: const TextStyle(color: Colors.red))
                    else if (_searchResult != null)
                      ListTile(
                        leading: Avatar(
                          displayName: _searchResult!['display_name'] ?? 'User',
                          imageUrl: _searchResult!['avatar_url'],
                          size: 40,
                        ),
                        title: Text(_searchResult!['display_name'] ?? 'No Name'),
                        subtitle: Text(_searchResult!['email'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add_alt_1, color: Colors.blue),
                          onPressed: () => sendRequest(_searchResult!['id']),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsListProvider);
    final requestsAsync = ref.watch(incomingRequestsListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_outlined),
              onPressed: _showAddContactDialog,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Contacts', icon: Icon(Icons.people)),
              Tab(text: 'Requests', icon: Icon(Icons.mail_outline)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Contacts list
            RefreshIndicator(
              onRefresh: () => ref.read(contactsListProvider.notifier).refresh(),
              child: contactsAsync.when(
                data: (contacts) {
                  if (contacts.isEmpty) {
                    return const Center(
                      child: Text('No contacts added yet. Search by email to connect!'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        leading: Avatar(
                          displayName: contact['display_name'] ?? 'User',
                          imageUrl: contact['avatar_url'],
                          size: 44,
                        ),
                        title: Text(contact['display_name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(contact['status_message'] ?? 'Online'),
                        onTap: () async {
                          // Try to create a conversation in Supabase (Edge Function will assert connection exists)
                          try {
                            final result = await SupabaseService.client.functions.invoke(
                              'create-conversation',
                              body: {
                                'type': 'direct',
                                'memberIds': [contact['id']],
                              },
                            );
                            if (context.mounted && result.status == 200) {
                              final convId = result.data['conversationId'] as String;
                              context.push('/chat/$convId');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to open chat: $e')),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Failed to load contacts: $err')),
              ),
            ),

            // Tab 2: Requests list
            RefreshIndicator(
              onRefresh: () => ref.read(incomingRequestsListProvider.notifier).refresh(),
              child: requestsAsync.when(
                data: (requests) {
                  if (requests.isEmpty) {
                    return const Center(
                      child: Text('No pending connection requests.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      final sender = req['profiles'] as Map<String, dynamic>? ?? {};
                      return ListTile(
                        leading: Avatar(
                          displayName: sender['display_name'] ?? 'User',
                          imageUrl: sender['avatar_url'],
                          size: 44,
                        ),
                        title: Text(sender['display_name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(sender['email'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () async {
                                await ref.read(incomingRequestsListProvider.notifier).accept(req['id']);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () async {
                                await ref.read(incomingRequestsListProvider.notifier).decline(req['id']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Failed to load requests: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
