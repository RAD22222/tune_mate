// lib/features/chat/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showSendButton = _textController.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final replyTarget = ref.read(replyTargetProvider);
    ref.read(chatProvider(widget.conversationId).notifier).sendTextMessage(
          text,
          replyTo: replyTarget,
        );

    _textController.clear();
    ref.read(replyTargetProvider.notifier).clear();
    
    // Scroll to bottom
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatProvider(widget.conversationId));
    final currentUser = ref.watch(authStateProvider).value;
    final typingUsers = ref.watch(typingIndicatorProvider(widget.conversationId)).value ?? [];
    final replyTarget = ref.watch(replyTargetProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const Avatar(
              displayName: 'Sarah Jenkins',
              imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
              size: 38,
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sarah Jenkins',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (typingUsers.isNotEmpty)
                    const Text(
                      'typing...',
                      style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                    )
                  else
                    const Text(
                      'online',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // Trigger a mock call
              context.push('/call/active/mock_video_call');
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {
              context.push('/call/active/mock_voice_call');
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Display reversed messages list
                final reversedMessages = messages.reversed.toList();
                
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) {
                    final message = reversedMessages[index];
                    final isOwn = message.senderId == currentUser?.id;
                    
                    return MessageBubble(
                      message: message,
                      isOwn: isOwn,
                      onReply: () {
                        ref.read(replyTargetProvider.notifier).set(message);
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(message: 'Loading messages...'),
              error: (err, stack) => ErrorView(
                error: err.toString(),
                onRetry: () => ref.invalidate(chatProvider(widget.conversationId)),
              ),
            ),
          ),
          
          // Reply preview strip
          if (replyTarget != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 20, color: Colors.grey),
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Replying to',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                        ),
                        Text(
                          replyTarget.content ?? 'Media attachment',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => ref.read(replyTargetProvider.notifier).clear(),
                  ),
                ],
              ),
            ),

          // Message input bar
          Container(
            padding: const EdgeInsets.all(AppSizes.p8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
                    onPressed: () {
                      // Stub emoji picker bottom sheet
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          height: 250,
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: Text('Emoji Picker Sheet (Stub)'),
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppSizes.r16),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: AppSizes.p12),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              maxLines: 5,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: () {
                              // Open attachments bottom sheet
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(AppSizes.p24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildAttachmentOption(Icons.camera_alt, 'Camera', Colors.red),
                                          _buildAttachmentOption(Icons.image, 'Gallery', Colors.purple),
                                          _buildAttachmentOption(Icons.insert_drive_file, 'Document', Colors.blue),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildAttachmentOption(Icons.audiotrack, 'Audio', Colors.orange),
                                          _buildAttachmentOption(Icons.gif, 'GIF', Colors.green),
                                          _buildAttachmentOption(Icons.location_on, 'Location', Colors.teal),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p8),
                  FloatingActionButton.small(
                    onPressed: _showSendButton ? _sendMessage : null,
                    elevation: 0,
                    backgroundColor: _showSendButton
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    child: Icon(
                      _showSendButton ? Icons.send : Icons.mic,
                      color: _showSendButton ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwn;
  final VoidCallback onReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () {
                // Show actions dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Message Actions'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.reply),
                          title: const Text('Reply'),
                          onTap: () {
                            Navigator.pop(context);
                            onReply();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.copy),
                          title: const Text('Copy Text'),
                          onTap: () {
                            Navigator.pop(context);
                            // Clipboard actions can go here
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isOwn
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppSizes.r12),
                    topRight: const Radius.circular(AppSizes.r12),
                    bottomLeft: isOwn ? const Radius.circular(AppSizes.r12) : Radius.zero,
                    bottomRight: isOwn ? Radius.zero : const Radius.circular(AppSizes.r12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.replyTo != null) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          message.replyTo!.content ?? 'Attachment',
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    _buildMessageContent(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.createdAt.toMessageTime(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (isOwn) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content ?? '',
          style: TextStyle(
            color: isOwn
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.fileUrl!,
                fit: BoxFit.cover,
              ),
            ),
            if (message.content != null) ...[
              const SizedBox(height: 6),
              Text(message.content!),
            ],
          ],
        );
      case MessageType.gif:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(message.fileUrl!),
        );
      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow),
            const SizedBox(width: 8),
            Container(
              width: 120,
              height: 2,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              '${(message.audioDurationMs ?? 0) ~/ 1000}s',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      default:
        return Text(message.content ?? '');
    }
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(strokeWidth: 1, color: Colors.grey),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 12, color: Colors.red);
    }
  }
}
