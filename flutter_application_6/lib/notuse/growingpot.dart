class GrowingPot {
  int? growingPotId;
  int growingId;
  int typePotId;
  int? index;
  String? imgPath;
  String? aiResult;
  String status;
  int deviceId;

  GrowingPot({
    this.growingPotId,
    required this.growingId,
    required this.typePotId,
    this.index,
    this.imgPath,
    this.aiResult,
    this.status = 'active',
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'growing_pot_id': growingPotId,
      'growing_id': growingId,
      'type_pot_id': typePotId,
      'index': index,
      'img_path': imgPath,
      'ai_result': aiResult,
      'status': status,
      'device_id': deviceId,
    };
  }

  factory GrowingPot.fromMap(Map<String, dynamic> map) {
    return GrowingPot(
      growingPotId: map['growing_pot_id'],
      growingId: map['growing_id'],
      typePotId: map['type_pot_id'],
      index: map['index'],
      imgPath: map['img_path'],
      aiResult: map['ai_result'],
      status: map['status'] ?? 'active',
      deviceId: map['device_id'],
    );
  }
}
