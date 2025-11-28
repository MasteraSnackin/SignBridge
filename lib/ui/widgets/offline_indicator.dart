import 'package:flutter/material.dart';

/// Offline indicator widget to reassure users about privacy
/// Highlights the key feature of 100% offline operation
class OfflineIndicator extends StatelessWidget {
  final bool isCompact;

  const OfflineIndicator({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactIndicator();
    }
    return _buildFullIndicator();
  }

  Widget _buildFullIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.offline_bolt,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            '100% Offline',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.lock,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactIndicator() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.offline_bolt,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

/// Privacy badge widget
class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          const Text(
            'Private',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status bar with offline and privacy indicators
class StatusBar extends StatelessWidget {
  final bool showOffline;
  final bool showPrivacy;
  final String? customStatus;

  const StatusBar({
    super.key,
    this.showOffline = true,
    this.showPrivacy = false,
    this.customStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showOffline) ...[
            const OfflineIndicator(isCompact: true),
            const SizedBox(width: 8),
          ],
          if (showPrivacy) ...[
            const PrivacyBadge(),
            const SizedBox(width: 8),
          ],
          if (customStatus != null)
            Text(
              customStatus!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}