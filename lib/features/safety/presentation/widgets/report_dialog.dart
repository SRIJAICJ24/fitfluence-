import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../config/theme.dart';
import '../../../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../controllers/safety_controller.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String reportedUserId;
  final String reportedUserName;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  String? _selectedReason;
  final TextEditingController _commentController = TextEditingController();

  final List<String> _reasons = [
    'harassment',
    'inappropriate',
    'spam',
    'fake',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report ${widget.reportedUserName}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const Text('Why are you reporting this user?', style: TextStyle(color: AppColors.slateGrey)),
            const SizedBox(height: 12),
            
            // Reasons Dropdown
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.deepSlate,
              value: _selectedReason,
              items: _reasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(
                    reason[0].toUpperCase() + reason.substring(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedReason = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.deepSlate,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Additional details (optional)',
                hintStyle: const TextStyle(color: AppColors.slateGrey),
                filled: true,
                fillColor: AppColors.deepSlate,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: _selectedReason == null ? null : _submitReport,
                  child: const Text('Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport() {
    ref.read(safetyControllerProvider.notifier).reportUser(
      reportedUserId: widget.reportedUserId,
      reportType: _selectedReason!,
      description: _commentController.text,
    );
    Navigator.pop(context); // Close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted. We will review it shortly.')),
    );
  }
}
