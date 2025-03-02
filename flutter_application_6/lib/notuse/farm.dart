class Farm {
  final int farmId;
  final String farmName;
  final String? farmType;
  final String? farmDescription;
  final bool farmStatus;
  final double? temperature;
  final double? humidity;

  Farm({
    required this.farmId,
    required this.farmName,
    this.farmType,
    this.farmDescription,
    required this.farmStatus,
    this.temperature,
    this.humidity,
  });

  // ถ้าต้องการแปลงจาก JSON
  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      farmId: json['farm_id'],
      farmName: json['farm_name'],
      farmType: json['farm_type'],
      farmDescription: json['farm_description'],
      farmStatus: json['farm_status'] == 1,
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
    );
  }
}
