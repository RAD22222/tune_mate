// lib/features/calling/presentation/screens/active_call_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/avatar.dart';
import '../providers/call_provider.dart';

class ActiveCallScreen extends ConsumerStatefulWidget {
  final String callId;

  const ActiveCallScreen({super.key, required this.callId});

  @override
  ConsumerState<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends ConsumerState<ActiveCallScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;

  double _pipX = 20.0;
  double _pipY = 100.0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Remote Video Feed (Fills the screen)
          Positioned.fill(
            child: _isCameraOff
                ? Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Avatar(
                            displayName: 'Sarah Jenkins',
                            imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150',
                            size: 100,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sarah Jenkins',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                : Image.network(
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600',
                    fit: BoxFit.cover,
                  ),
          ),

          // Draggable Local Video PiP (Bottom-Right corner defaults)
          Positioned(
            left: _pipX,
            top: _pipY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _pipX = (_pipX + details.delta.dx).clamp(20.0, size.width - 140.0);
                  _pipY = (_pipY + details.delta.dy).clamp(40.0, size.height - 220.0);
                });
              },
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Duration Timer & Top Controls
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDuration(_secondsElapsed),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Action buttons row (bottom)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
              decoration: BoxDecoration(
                color: Colors.black87.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isCameraOff ? Icons.videocam_off : Icons.videocam,
                      color: _isCameraOff ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCameraOff = !_isCameraOff;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      color: _isSpeakerOn ? Colors.green : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                      });
                    },
                  ),
                  FloatingActionButton(
                    heroTag: 'end_call_btn',
                    onPressed: () {
                      ref.read(callStateProvider.notifier).endCall();
                      context.pop();
                    },
                    backgroundColor: Colors.red,
                    mini: true,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
