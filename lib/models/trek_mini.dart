class TrekMini {
  final int id;
  final String name;

  const TrekMini({
    required this.id,
    required this.name,
  });

  factory TrekMini.fromJson(Map<String, dynamic> json) {
    return TrekMini(
      id: json['id'] as int? ?? -1,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
