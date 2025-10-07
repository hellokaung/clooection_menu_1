import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/home_provider.dart';

/// Displays a modal dialog prompting the user to restart the app after new data is downloaded.
void showRestartNoticeDialog(BuildContext context, HomeProvider provider) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    // Prevents closing by tapping outside, forcing the user to acknowledge the update.
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Modern M3 rounded corners
      ),
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Icon
            Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'dataUpdated'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            Text(
              // Using localization key for flexible text
              'new_data_available_restart'.tr(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // Action Button
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                // Use a prominent FilledButton for the critical action
                onPressed: () {
                  // 1. Clear the persistent flag and trigger data reload (simulating app restart data flow)
                  provider.clearRestartNotice();
                  // 2. Dismiss the dialog
                  Navigator.of(ctx).pop();

                  // In a production app, the 'clearRestartNotice' logic ensures that
                  // subsequent data requests pick up the fresh data, which is the
                  // essential outcome of a restart in this context.
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  'restartApp'.tr(), // Localized button text
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    120,
                    48,
                  ), // Ensure a large touch target
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
