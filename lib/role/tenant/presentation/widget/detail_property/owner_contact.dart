import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OwnerContact extends StatelessWidget {
  const OwnerContact({
    super.key,
    required this.landlordId,
    this.ownerName,
    this.avatarUrl,
    this.onCall,
    this.onChat,
    this.onEdit,
  });

  final String landlordId;
  final String? ownerName;
  final String? avatarUrl;
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final name = _resolveName();

    return Container(
      padding: const EdgeInsets.symmetric(),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Owner',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _ContactIcon(icon: LucideIcons.phone, onTap: onCall),
              const SizedBox(width: 10),
              _ContactIcon(icon: LucideIcons.messageSquare, onTap: onChat),
              if (onEdit != null) ...[
                const SizedBox(width: 10),
                _ContactIcon(icon: LucideIcons.edit, onTap: onEdit),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _resolveName() {
    if (ownerName != null && ownerName!.trim().isNotEmpty) {
      return ownerName!.trim();
    }
    if (landlordId.isNotEmpty) {

      return 'Owner ${landlordId.substring(0, landlordId.length > 6 ? 6 : landlordId.length)}';
    }
    return 'Owner';
  }
}

class _ContactIcon extends StatelessWidget {
  const _ContactIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.teal.withOpacity(0.08),
        ),
        child: Icon(icon, size: 18, color: Colors.teal),
      ),
    );
  }
}
