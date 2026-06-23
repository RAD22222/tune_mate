// lib/features/conversations/presentation/screens/conversations_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/conversations_provider.dart';
import '../../domain/conversation.dart';

class ConversationsListScreen extends ConsumerStatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  ConsumerState<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends ConsumerState<ConversationsListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: AppStrings.searchHint,
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : const Text(AppStrings.conversationsTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'settings') {
                context.push('/settings');
              } else if (val == 'logout') {
                ref.read(authStateProvider.notifier).logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          final filteredList = conversations.where((c) {
            return c.name.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.noConversations,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppStrings.startChatting,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(conversationsProvider);
            },
            child: ListView.separated(
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 76),
              itemBuilder: (context, index) {
                final conversation = filteredList[index];
                return Slidable(
                  key: ValueKey(conversation.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Chat'),
                              content: const Text(AppStrings.deleteConfirmation),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref.read(conversationsProvider.notifier).deleteConversation(conversation.id);
                          }
                        },
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ConversationTile(conversation: conversation),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading chats...'),
        error: (err, stack) => ErrorView(
          error: err.toString(),
          onRetry: () => ref.invalidate(conversationsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/conversations/new'),
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const ConversationTile({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      onTap: () => context.push('/chat/${conversation.id}'),
      leading: Avatar(
        displayName: conversation.name,
        imageUrl: conversation.avatarUrl,
        size: 50,
        isOnline: conversation.unreadCount > 0, // Mock online status with unread status for demonstration
      ),
      title: Text(
        conversation.name,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        conversation.lastMessage?.content ?? 'Start chatting!',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasUnread ? Colors.black87 : Colors.grey,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation.updatedAt.toRelativeTime(),
            style: TextStyle(
              fontSize: 12,
              color: hasUnread ? Theme.of(context).colorScheme.primary : Colors.grey,
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
