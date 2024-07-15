class Branch {
  String name = "";
  String id = "";
  String address = "";
  String location = "";
  String phoneNumber = "";

  Branch({
    required this.name,
    required this.id,
    required this.address,
    required this.location,
    required this.phoneNumber,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'].toString(),
      id: json['id'],
      address: json['address'].toString(),
      location: json['location'].toString(),
      phoneNumber: json['phoneNumber'].toString(),
    );
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      name: map['name'].toString(),
      id: map['id'],
      address: map['address'].toString(),
      location: map['location'].toString(),
      phoneNumber: map['phoneNumber'].toString(),
    );
  }

  Map<String, Object?> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'id': id,
      'address': address,
      'location': location,
      'phoneNumber': phoneNumber,
    };
    return map;
  }
}
