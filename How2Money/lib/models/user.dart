class User {
  final String id;
  final String displayName;
  final FinancialBackground? background;
  final bool isPremium;
  final String currency;
  final bool hasCompletedOnboarding;

  User({
    required this.id,
    required this.displayName,
    this.background,
    this.isPremium = false,
    this.currency = 'ZAR',
    this.hasCompletedOnboarding = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'background': background?.toString(),
      'isPremium': isPremium,
      'currency': currency,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      background: json['background'] != null
          ? FinancialBackground.values.firstWhere(
              (e) => e.toString() == json['background'],
              orElse: () => FinancialBackground.none,
            )
          : null,
      isPremium: json['isPremium'] ?? false,
      currency: json['currency'] ?? 'ZAR',
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }

  User copyWith({
    String? id,
    String? displayName,
    FinancialBackground? background,
    bool? isPremium,
    String? currency,
    bool? hasCompletedOnboarding,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      background: background ?? this.background,
      isPremium: isPremium ?? this.isPremium,
      currency: currency ?? this.currency,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

enum FinancialBackground {
  student,
  employed,
  freelance,
  none,
}

extension FinancialBackgroundExtension on FinancialBackground {
  String get displayName {
    switch (this) {
      case FinancialBackground.student:
        return 'Student';
      case FinancialBackground.employed:
        return 'Employed';
      case FinancialBackground.freelance:
        return 'Freelance';
      case FinancialBackground.none:
        return 'None';
    }
  }
}


