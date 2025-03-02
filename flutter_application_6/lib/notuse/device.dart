class Device {
  final int deviceId;
  final String deviceName;
  final String? description;
  final String status;

  Device({
    required this.deviceId,
    required this.deviceName,
    this.description,
    this.status = 'inactive',
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      description: json['description'],
      status: json['status'] ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'description': description,
      'status': status,
    };
  }
}
