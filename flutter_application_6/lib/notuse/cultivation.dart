class Cultivation {
  final int cultivationId;
  final int farmId;

  Cultivation({
    required this.cultivationId,
    required this.farmId,
  });

  factory Cultivation.fromJson(Map<String, dynamic> json) {
    return Cultivation(
      cultivationId: json['cultivation_id'],
      farmId: json['farm_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cultivation_id': cultivationId,
      'farm_id': farmId,
    };
  }
}
