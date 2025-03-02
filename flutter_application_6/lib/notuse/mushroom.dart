class Mushroom {
  int? typePotId;
  String typePotName;
  String? description;
  bool status;

  Mushroom({
    this.typePotId,
    required this.typePotName,
    this.description,
    this.status = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'type_pot_id': typePotId,
      'type_pot_name': typePotName,
      'description': description,
      'status': status ? 1 : 0,
    };
  }

  factory Mushroom.fromMap(Map<String, dynamic> map) {
    return Mushroom(
      typePotId: map['type_pot_id'],
      typePotName: map['type_pot_name'],
      description: map['description'],
      status: map['status'] == 1,
    );
  }
}
