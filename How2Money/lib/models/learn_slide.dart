class LearnSlide {
  final String id;
  final String title;
  final String category;
  final List<String> bulletPoints;
  final bool isCompleted;
  final int order;

  LearnSlide({
    required this.id,
    required this.title,
    required this.category,
    required this.bulletPoints,
    this.isCompleted = false,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'bulletPoints': bulletPoints,
      'isCompleted': isCompleted,
      'order': order,
    };
  }

  factory LearnSlide.fromJson(Map<String, dynamic> json) {
    return LearnSlide(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      bulletPoints: List<String>.from(json['bulletPoints'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  LearnSlide copyWith({
    String? id,
    String? title,
    String? category,
    List<String>? bulletPoints,
    bool? isCompleted,
    int? order,
  }) {
    return LearnSlide(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }
}


