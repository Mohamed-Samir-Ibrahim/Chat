import 'package:chat_app/core/model/user_model.dart';
import 'package:chat_app/screen/auth_screen.dart';
import 'package:chat_app/screen/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  static const String routeName = 'auth-wrapper';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      return AuthScreen();
    } else {
      return ChatScreen();
    }
  }
}
