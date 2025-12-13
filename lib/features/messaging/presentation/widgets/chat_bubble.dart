import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isOwn;
  final DateTime timestamp;
  final bool isRead;
  final String? mediaUrl;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isOwn,
    required this.timestamp,
    this.isRead = false,
    this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (mediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    mediaUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isOwn ? AppColors.volt.withOpacity(0.2) : AppColors.midnightBlue.withOpacity(0.6),
                border: Border.all(
                  color: isOwn ? AppColors.volt.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isOwn ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isOwn ? const Radius.circular(4) : const Radius.circular(20),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isOwn ? AppColors.volt : AppColors.lightSlate,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(timestamp),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.slateGrey,
                  ),
                ),
                if (isOwn) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead ? AppColors.volt : AppColors.slateGrey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
