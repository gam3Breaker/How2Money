import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../theme/app_theme.dart';

class DebtListScreen extends StatelessWidget {
  const DebtListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splitProvider = Provider.of<SplitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
      ),
      body: splitProvider.debts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No debts yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: splitProvider.debts.length,
              itemBuilder: (context, index) {
                final debt = splitProvider.debts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: debt.isPaid
                      ? AppTheme.success.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: debt.isPaid
                          ? AppTheme.success
                          : AppTheme.primaryTeal,
                      child: Icon(
                        debt.isPaid ? Icons.check : Icons.money_off,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '${debt.fromPerson} owes ${debt.toPerson}',
                      style: TextStyle(
                        decoration: debt.isPaid
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('R${debt.amount.toStringAsFixed(2)}'),
                        if (debt.description != null)
                          Text(debt.description!),
                        if (debt.weeklyReminderEnabled)
                          const Chip(
                            label: Text('Reminder enabled'),
                            avatar: Icon(Icons.notifications, size: 16),
                          ),
                      ],
                    ),
                    trailing: debt.isPaid
                        ? const Icon(Icons.check_circle, color: AppTheme.success)
                        : PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('Mark as Paid'),
                                onTap: () {
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      splitProvider.markDebtPaid(debt.id);
                                    },
                                  );
                                },
                              ),
                              PopupMenuItem(
                                child: Text(
                                  debt.weeklyReminderEnabled
                                      ? 'Disable Reminder'
                                      : 'Enable Reminder',
                                ),
                                onTap: () {
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      splitProvider.toggleDebtReminder(
                                        debt.id,
                                        !debt.weeklyReminderEnabled,
                                      );
                                    },
                                  );
                                },
                              ),
                              PopupMenuItem(
                                child: const Text(
                                  'Send Reminder',
                                  style: TextStyle(color: AppTheme.primaryTeal),
                                ),
                                onTap: () {
                                  final debtToRemind = debt;
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      _showReminderDialog(context, debtToRemind);
                                    },
                                  );
                                },
                              ),
                              const PopupMenuItem(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: AppTheme.error),
                                ),
                                onTap: null, // TODO: Implement delete
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }

  void _showReminderDialog(BuildContext context, dynamic debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Reminder'),
        content: Text(
          'Send a reminder to ${debt.fromPerson} about the R${debt.amount.toStringAsFixed(2)} debt?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement real SMS/WhatsApp sending
              // For now, show a mock share dialog
              _showMockShareDialog(context, debt);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showMockShareDialog(BuildContext context, dynamic debt) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Reminder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mock: In production, this would open SMS/WhatsApp with:',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Hey ${debt.fromPerson}, just a reminder that you owe me R${debt.amount.toStringAsFixed(2)}. Thanks!',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder sent (mock)'),
                        ),
                      );
                    },
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
