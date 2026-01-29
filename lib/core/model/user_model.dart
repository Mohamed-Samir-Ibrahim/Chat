class UserModel {
  String? uid;
  String? name;
  String? email;
  String? phone;

  UserModel({this.uid, this.name, this.email, this.phone});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'email': email, 'phone': phone};
  }
}
