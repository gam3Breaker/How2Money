import 'package:flutter_test/flutter_test.dart';
import 'package:moneywise/services/split_algorithm.dart';
import 'package:moneywise/models/split_item.dart';
import 'package:uuid/uuid.dart';

// Note: These tests demonstrate the split algorithm logic
// Run with: flutter test test/split_algorithm_test.dart

void main() {
  group('SplitAlgorithm', () {
    test('should calculate equal split when everyone has enough cash', () {
      final items = [
        SplitItem(
          id: const Uuid().v4(),
          name: 'Pizza',
          price: 300.0,
          participants: ['person1', 'person2', 'person3'],
        ),
      ];

      final participants = [
        Participant(
          id: 'person1',
          name: 'Alice',
          cashOnHand: 200.0,
        ),
        Participant(
          id: 'person2',
          name: 'Bob',
          cashOnHand: 200.0,
        ),
        Participant(
          id: 'person3',
          name: 'Charlie',
          cashOnHand: 200.0,
        ),
      ];

      final results = SplitAlgorithm.calculateSplit(
        items: items,
        participants: participants,
      );

      expect(results.length, 3);
      expect(results[0].amountOwed, 100.0);
      expect(results[0].amountPaid, 100.0);
      expect(results[0].remaining, 0.0);
    });

    test('should redistribute when someone has insufficient cash', () {
      final items = [
        SplitItem(
          id: const Uuid().v4(),
          name: 'Dinner',
          price: 300.0,
          participants: ['person1', 'person2', 'person3'],
        ),
      ];

      final participants = [
        Participant(
          id: 'person1',
          name: 'Alice',
          cashOnHand: 200.0,
        ),
        Participant(
          id: 'person2',
          name: 'Bob',
          cashOnHand: 50.0, // Insufficient
        ),
        Participant(
          id: 'person3',
          name: 'Charlie',
          cashOnHand: 200.0,
        ),
      ];

      final results = SplitAlgorithm.calculateSplit(
        items: items,
        participants: participants,
      );

      expect(results.length, 3);
      
      // Bob should pay what he has
      final bobResult = results.firstWhere((r) => r.participantName == 'Bob');
      expect(bobResult.amountPaid, 50.0);
      expect(bobResult.remaining, greaterThan(0.0));

      // Alice and Charlie should cover the remainder
      final aliceResult = results.firstWhere((r) => r.participantName == 'Alice');
      final charlieResult = results.firstWhere((r) => r.participantName == 'Charlie');
      
      expect(aliceResult.amountPaid + charlieResult.amountPaid + bobResult.amountPaid,
          closeTo(300.0, 0.01));
    });

    test('should handle empty items', () {
      final results = SplitAlgorithm.calculateSplit(
        items: [],
        participants: [],
      );

      expect(results, isEmpty);
    });

    test('should handle single participant', () {
      final items = [
        SplitItem(
          id: const Uuid().v4(),
          name: 'Lunch',
          price: 100.0,
          participants: ['person1'],
        ),
      ];

      final participants = [
        Participant(
          id: 'person1',
          name: 'Alice',
          cashOnHand: 100.0,
        ),
      ];

      final results = SplitAlgorithm.calculateSplit(
        items: items,
        participants: participants,
      );

      expect(results.length, 1);
      expect(results[0].amountOwed, 100.0);
      expect(results[0].amountPaid, 100.0);
      expect(results[0].remaining, 0.0);
    });
  });
}
