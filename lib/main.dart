import 'package:chat_app/core/model/user_model.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/screen/auth_wrapper.dart';
import 'package:chat_app/screen/chat/chat_screen.dart';
import 'package:chat_app/shared/auth_service.dart';
import 'package:chat_app/shared/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        StreamProvider<UserModel?>(
          create: (context) => context.read<AuthService>().currentUserStream,
          initialData: null,
          catchError: (_, err) => null,
        ),
      ],
      child: Consumer(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Chat',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            initialRoute: AuthWrapper.routeName,
            routes: {
              ChatScreen.routeName: (context) => ChatScreen(),
              AuthWrapper.routeName: (context) => AuthWrapper(),
            },
          );
        },
      ),
    );
  }
}

//130
