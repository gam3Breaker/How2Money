class Debt {
  final String id;
  final String fromPerson;
  final String toPerson;
  final double amount;
  final String? description;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? paidAt;
  final bool weeklyReminderEnabled;

  Debt({
    required this.id,
    required this.fromPerson,
    required this.toPerson,
    required this.amount,
    this.description,
    this.isPaid = false,
    required this.createdAt,
    this.paidAt,
    this.weeklyReminderEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromPerson': fromPerson,
      'toPerson': toPerson,
      'amount': amount,
      'description': description,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'weeklyReminderEnabled': weeklyReminderEnabled,
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] ?? '',
      fromPerson: json['fromPerson'] ?? '',
      toPerson: json['toPerson'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'],
      isPaid: json['isPaid'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      weeklyReminderEnabled: json['weeklyReminderEnabled'] ?? false,
    );
  }

  Debt copyWith({
    String? id,
    String? fromPerson,
    String? toPerson,
    double? amount,
    String? description,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? paidAt,
    bool? weeklyReminderEnabled,
  }) {
    return Debt(
      id: id ?? this.id,
      fromPerson: fromPerson ?? this.fromPerson,
      toPerson: toPerson ?? this.toPerson,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      weeklyReminderEnabled:
          weeklyReminderEnabled ?? this.weeklyReminderEnabled,
    );
  }
}


