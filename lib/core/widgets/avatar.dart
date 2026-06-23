// lib/core/widgets/avatar.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final double size;
  final bool isOnline;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    required this.displayName,
    this.imageUrl,
    this.size = 40.0,
    this.isOnline = false,
    this.onTap,
  });

  Color _getInitialsColor(String name) {
    // Generate a stable color from display name
    final hash = name.hashCode;
    const colors = [
      Color(0xFFE57373),
      Color(0xFFF06292),
      Color(0xFFBA68C8),
      Color(0xFF9575CD),
      Color(0xFF7986CB),
      Color(0xFF64B5F6),
      Color(0xFF4FC3F7),
      Color(0xFF4DB6AC),
      Color(0xFF81C784),
      Color(0xFFFFB74D),
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => Container(
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    } else {
      avatarWidget = _buildFallback();
    }

    if (onTap != null) {
      avatarWidget = GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(child: avatarWidget),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: size * 0.05,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        color: _getInitialsColor(displayName),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(displayName),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
