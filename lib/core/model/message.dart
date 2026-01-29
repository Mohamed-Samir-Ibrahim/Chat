import 'package:chat_app/core/constant/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String message;
  final String id;
  final Timestamp? createdAt;

  Message({required this.message, required this.id, this.createdAt,});

  factory Message.fromJson(json) {
    return Message(
      message: (json[kMessage] as String?)?.trim() ?? '[Deleted/Empty Message]',
      id: (json['id'] as String?) ?? 'unknown@user.com',
      // createdAt: json[kCreatedAt] as Timestamp?,
    );
  }
}
