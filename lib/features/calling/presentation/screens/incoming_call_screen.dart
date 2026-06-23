// lib/features/calling/presentation/screens/incoming_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/avatar.dart';
import '../providers/call_provider.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Caller Avatar with pulsing ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150 + (30 * _pulseController.value),
                      height: 150 + (30 * _pulseController.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withValues(alpha: 0.2 * (1.0 - _pulseController.value)),
                      ),
                    ),
                    const Avatar(
                      displayName: 'Sarah Jenkins',
                      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
                      size: 130,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.p24),
            Text(
              'Sarah Jenkins',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.p8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.video_call, color: Colors.green, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Incoming Video Call',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Decline and Accept buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p48, vertical: AppSizes.p32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'decline_btn',
                        onPressed: () {
                          ref.read(callStateProvider.notifier).declineCall();
                          context.pop();
                        },
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.decline,
                        style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'accept_btn',
                        onPressed: () {
                          ref.read(callStateProvider.notifier).acceptCall();
                          context.replace('/call/active/mock_video_call');
                        },
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.call, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.accept,
                        style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
