import 'package:flutter/foundation.dart';
import '../models/split_item.dart';
import '../models/debt.dart';
import '../services/local_storage_service.dart';
import '../services/split_algorithm.dart';
import 'package:uuid/uuid.dart';

class SplitProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final Uuid _uuid = const Uuid();

  List<SplitItem> _items = [];
  List<Participant> _participants = [];
  List<SplitResult>? _splitResults;
  List<Debt> _debts = [];

  List<SplitItem> get items => _items;
  List<Participant> get participants => _participants;
  List<SplitResult>? get splitResults => _splitResults;
  List<Debt> get debts => _debts;

  SplitProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _items = await _storage.getSplits();
    _participants = await _storage.getParticipants();
    _debts = await _storage.getDebts();
    notifyListeners();
  }

  void addItem(SplitItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void addParticipant(Participant participant) {
    _participants.add(participant);
    notifyListeners();
  }

  void updateParticipant(Participant participant) {
    final index = _participants.indexWhere((p) => p.id == participant.id);
    if (index != -1) {
      _participants[index] = participant;
      notifyListeners();
    }
  }

  void removeParticipant(String participantId) {
    _participants.removeWhere((p) => p.id == participantId);
    notifyListeners();
  }

  Future<void> calculateSplit() async {
    _splitResults = SplitAlgorithm.calculateSplit(
      items: _items,
      participants: _participants,
    );
    notifyListeners();
  }

  Future<void> saveSplitAndCreateDebts(String payerId, {String? description}) async {
    if (_splitResults == null) {
      await calculateSplit();
    }

    // Save split items and participants
    await _storage.saveSplit(_items, _participants);

    // Generate debts
    if (_splitResults != null) {
      final newDebts = SplitAlgorithm.generateDebts(
        results: _splitResults!,
        payerId: payerId,
        description: description,
      );

      for (var debt in newDebts) {
        await _storage.saveDebt(debt);
        _debts.add(debt);
      }
    }

    notifyListeners();
  }

  Future<void> markDebtPaid(String debtId) async {
    final debt = _debts.firstWhere((d) => d.id == debtId);
    final updatedDebt = debt.copyWith(
      isPaid: true,
      paidAt: DateTime.now(),
    );
    await _storage.saveDebt(updatedDebt);
    await _loadData();
  }

  Future<void> toggleDebtReminder(String debtId, bool enabled) async {
    final debt = _debts.firstWhere((d) => d.id == debtId);
    final updatedDebt = debt.copyWith(weeklyReminderEnabled: enabled);
    await _storage.saveDebt(updatedDebt);
    await _loadData();
  }

  Future<void> deleteDebt(String debtId) async {
    await _storage.deleteDebt(debtId);
    await _loadData();
  }

  void clearSplit() {
    _items = [];
    _participants = [];
    _splitResults = null;
    notifyListeners();
  }
}


