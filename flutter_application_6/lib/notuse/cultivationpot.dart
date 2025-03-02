class CultivationPot {
  final int cultivationPotId;
  final int cultivationId;
  final int typePotId;
  final int? index;
  final String? imgPath;
  final String? aiResult;
  final String status;
  final int deviceId;

  CultivationPot({
    required this.cultivationPotId,
    required this.cultivationId,
    required this.typePotId,
    this.index,
    this.imgPath,
    this.aiResult,
    this.status = 'active',
    required this.deviceId,
  });

  factory CultivationPot.fromJson(Map<String, dynamic> json) {
    return CultivationPot(
      cultivationPotId: json['cultivation_pot_id'],
      cultivationId: json['cultivation_id'],
      typePotId: json['type_pot_id'],
      index: json['index'],
      imgPath: json['img_path'],
      aiResult: json['ai_result'],
      status: json['status'] ?? 'active',
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cultivation_pot_id': cultivationPotId,
      'cultivation_id': cultivationId,
      'type_pot_id': typePotId,
      'index': index,
      'img_path': imgPath,
      'ai_result': aiResult,
      'status': status,
      'device_id': deviceId,
    };
  }
}
