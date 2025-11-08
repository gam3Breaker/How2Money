import '../models/split_item.dart';
import '../models/debt.dart';

/// Implements a fair split algorithm that considers cash on hand.
/// 
/// Algorithm:
/// 1. Calculate total amount to split
/// 2. Calculate equal share per person
/// 3. For each person:
///    - If they have >= equal share, they pay their share
///    - If they have < equal share, they pay what they have
/// 4. Redistribute remaining amount proportionally among those who can pay more
class SplitAlgorithm {
  /// Calculates how much each participant should pay
  /// 
  /// Returns a list of SplitResult with amountOwed, amountPaid, and remaining
  static List<SplitResult> calculateSplit({
    required List<SplitItem> items,
    required List<Participant> participants,
  }) {
    // Calculate total amount
    double totalAmount = 0.0;
    for (var item in items) {
      totalAmount += item.price;
    }

    if (participants.isEmpty || totalAmount == 0) {
      return [];
    }

    // Calculate equal share per person
    final Set<String> allParticipantIds = {};
    for (var item in items) {
      allParticipantIds.addAll(item.participants);
    }

    // Filter participants to only those in items
    final activeParticipants = participants
        .where((p) => allParticipantIds.contains(p.id))
        .toList();

    if (activeParticipants.isEmpty) {
      return [];
    }

    final equalShare = totalAmount / activeParticipants.length;

    // Initialize results
    final Map<String, SplitResult> results = {};
    for (var participant in activeParticipants) {
      results[participant.id] = SplitResult(
        participantId: participant.id,
        participantName: participant.name,
        amountOwed: equalShare,
        amountPaid: 0.0,
        remaining: equalShare,
      );
    }

    // First pass: pay what each person can afford
    double totalPaid = 0.0;
    final List<Participant> canPayMore = [];

    for (var participant in activeParticipants) {
      final result = results[participant.id]!;
      final cashAvailable = participant.cashOnHand;

      if (cashAvailable >= equalShare) {
        // Can pay full share
        result.amountPaid = equalShare;
        result.remaining = 0.0;
        totalPaid += equalShare;
        // Can contribute more if needed
        canPayMore.add(participant);
      } else {
        // Pay what they have
        result.amountPaid = cashAvailable;
        result.remaining = equalShare - cashAvailable;
        totalPaid += cashAvailable;
      }
    }

    // Second pass: redistribute remaining amount
    double remainingToDistribute = totalAmount - totalPaid;

    if (remainingToDistribute > 0.01 && canPayMore.isNotEmpty) {
      // Distribute proportionally based on available cash
      double totalAvailableCash = 0.0;
      for (var participant in canPayMore) {
        totalAvailableCash +=
            (participant.cashOnHand - results[participant.id]!.amountPaid);
      }

      if (totalAvailableCash > 0) {
        for (var participant in canPayMore) {
          final availableCash =
              participant.cashOnHand - results[participant.id]!.amountPaid;
          if (availableCash > 0) {
            final proportion = availableCash / totalAvailableCash;
            final additionalPayment = remainingToDistribute * proportion;

            // Don't exceed what they have
            final maxAdditional = participant.cashOnHand -
                results[participant.id]!.amountPaid;
            final actualAdditional = additionalPayment > maxAdditional
                ? maxAdditional
                : additionalPayment;

            results[participant.id]!.amountPaid += actualAdditional;
            results[participant.id]!.remaining -= actualAdditional;
          }
        }
      }
    }

    return results.values.toList();
  }

  /// Generates debts from split results
  static List<Debt> generateDebts({
    required List<SplitResult> results,
    required String payerId,
    String? description,
  }) {
    final List<Debt> debts = [];
    final payerResult = results.firstWhere(
      (r) => r.participantId == payerId,
      orElse: () => SplitResult(
        participantId: payerId,
        participantName: '',
        amountOwed: 0,
        amountPaid: 0,
        remaining: 0,
      ),
    );

    for (var result in results) {
      if (result.participantId != payerId && result.remaining > 0.01) {
        debts.add(Debt(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              '_${result.participantId}',
          fromPerson: result.participantName,
          toPerson: payerResult.participantName,
          amount: result.remaining,
          description: description ?? 'Split bill',
          createdAt: DateTime.now(),
        ));
      }
    }

    return debts;
  }
}
