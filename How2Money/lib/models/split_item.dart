class SplitItem {
  final String id;
  final String name;
  final double price;
  final List<String> participants;

  SplitItem({
    required this.id,
    required this.name,
    required this.price,
    required this.participants,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'participants': participants,
    };
  }

  factory SplitItem.fromJson(Map<String, dynamic> json) {
    return SplitItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      participants: List<String>.from(json['participants'] ?? []),
    );
  }
}

class Participant {
  final String id;
  final String name;
  final String? phone;
  final double cashOnHand;

  Participant({
    required this.id,
    required this.name,
    this.phone,
    this.cashOnHand = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'cashOnHand': cashOnHand,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      cashOnHand: (json['cashOnHand'] ?? 0.0).toDouble(),
    );
  }

  Participant copyWith({
    String? id,
    String? name,
    String? phone,
    double? cashOnHand,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      cashOnHand: cashOnHand ?? this.cashOnHand,
    );
  }
}

class SplitResult {
  final String participantId;
  final String participantName;
  final double amountOwed;
  final double amountPaid;
  final double remaining;

  SplitResult({
    required this.participantId,
    required this.participantName,
    required this.amountOwed,
    required this.amountPaid,
    required this.remaining,
  });
}


