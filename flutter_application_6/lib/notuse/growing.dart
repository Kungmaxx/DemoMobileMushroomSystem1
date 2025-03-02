class Growing {
  int? growingId;
  int farmId;

  Growing({
    this.growingId,
    required this.farmId,
  });

  Map<String, dynamic> toMap() {
    return {
      'growing_id': growingId,
      'farm_id': farmId,
    };
  }

  factory Growing.fromMap(Map<String, dynamic> map) {
    return Growing(
      growingId: map['growing_id'],
      farmId: map['farm_id'],
    );
  }
}
