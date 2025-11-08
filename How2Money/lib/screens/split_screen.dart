import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../providers/auth_provider.dart';
import '../models/split_item.dart';
import '../theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'debt_list_screen.dart';

class SplitScreen extends StatelessWidget {
  const SplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Split Bills & Debts'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt), text: 'Split Bill'),
              Tab(icon: Icon(Icons.list), text: 'Debts'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SplitBillTab(),
            DebtListScreen(),
          ],
        ),
      ),
    );
  }
}

class _SplitBillTab extends StatefulWidget {
  @override
  State<_SplitBillTab> createState() => _SplitBillTabState();
}

class _SplitBillTabState extends State<_SplitBillTab> {
  @override
  Widget build(BuildContext context) {
    final splitProvider = Provider.of<SplitProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Item button
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context, splitProvider),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 16),

          // Items list
          if (splitProvider.items.isNotEmpty) ...[
            Text(
              'Items (${splitProvider.items.length})',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            ...splitProvider.items.map((item) => Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      'R${item.price.toStringAsFixed(2)} - ${item.participants.length} people',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        splitProvider.removeItem(item.id);
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Add Participant button
          ElevatedButton.icon(
            onPressed: () => _showAddParticipantDialog(context, splitProvider),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Participant'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 16),

          // Participants list
          if (splitProvider.participants.isNotEmpty) ...[
            Text(
              'Participants (${splitProvider.participants.length})',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            ...splitProvider.participants.map((participant) => Card(
                  child: ListTile(
                    title: Text(participant.name),
                    subtitle: Text(
                      'Cash: R${participant.cashOnHand.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditParticipantDialog(
                          context,
                          splitProvider,
                          participant,
                        );
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Calculate Split button
          if (splitProvider.items.isNotEmpty &&
              splitProvider.participants.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                await splitProvider.calculateSplit();
                if (context.mounted) {
                  _showSplitResults(context, splitProvider, authProvider);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryTeal,
              ),
              child: const Text('Calculate Split'),
            ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, SplitProvider provider) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final selectedParticipants = <String>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g., Pizza',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (R)',
                    hintText: 'e.g., 150.00',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Select Participants:'),
                ...provider.participants.map((p) => CheckboxListTile(
                      title: Text(p.name),
                      value: selectedParticipants.contains(p.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedParticipants.add(p.id);
                          } else {
                            selectedParticipants.remove(p.id);
                          }
                        });
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(priceController.text);
                if (nameController.text.isNotEmpty &&
                    price != null &&
                    price > 0 &&
                    selectedParticipants.isNotEmpty) {
                  provider.addItem(SplitItem(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    price: price,
                    participants: selectedParticipants.toList(),
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddParticipantDialog(
    BuildContext context,
    SplitProvider provider,
  ) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final cashController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Participant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., John',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                hintText: 'e.g., +27 82 123 4567',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cashController,
              decoration: const InputDecoration(
                labelText: 'Cash on Hand (R)',
                hintText: 'e.g., 200.00',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final cash = double.tryParse(cashController.text) ?? 0.0;
              if (nameController.text.isNotEmpty) {
                provider.addParticipant(Participant(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  phone: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  cashOnHand: cash,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditParticipantDialog(
    BuildContext context,
    SplitProvider provider,
    Participant participant,
  ) {
    final cashController =
        TextEditingController(text: participant.cashOnHand.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${participant.name}'),
        content: TextField(
          controller: cashController,
          decoration: const InputDecoration(
            labelText: 'Cash on Hand (R)',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final cash = double.tryParse(cashController.text) ?? 0.0;
              provider.updateParticipant(participant.copyWith(
                cashOnHand: cash,
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSplitResults(
    BuildContext context,
    SplitProvider splitProvider,
    AuthProvider authProvider,
  ) {
    final results = splitProvider.splitResults;
    if (results == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Split Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...results.map((result) => Card(
                  child: ListTile(
                    title: Text(result.participantName),
                    subtitle: Text(
                      'Owed: R${result.amountOwed.toStringAsFixed(2)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Paid: R${result.amountPaid.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (result.remaining > 0.01)
                          Text(
                            'Remaining: R${result.remaining.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.error,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final payerId = authProvider.user?.id ?? '';
                await splitProvider.saveSplitAndCreateDebts(payerId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Split saved and debts created!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Split & Create Debts'),
            ),
          ],
        ),
      ),
    );
  }
}
