import 'package:chat_app/core/constant/app_constants.dart';
import 'package:chat_app/core/model/message.dart';
import 'package:chat_app/core/model/user_model.dart';
import 'package:chat_app/screen/auth_screen.dart';
import 'package:chat_app/shared/auth_service.dart';
import 'package:chat_app/shared/theme_provider.dart';
import 'package:chat_app/widget/custom_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String routeName = 'chat-screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  CollectionReference ref = FirebaseFirestore.instance.collection(
    kMessageCollection,
  );

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserModel? currentUser = Provider.of<UserModel?>(
      context,
      listen: false,
    );
    final String currentEmail =
        currentUser?.email ?? 'unknown@user.com'; // fallbacfinal authService = Provider.of<AuthService>(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return StreamBuilder<QuerySnapshot>(
          stream: ref.orderBy(kCreatedAt, descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Message> messagesList = [];
              messagesList = snapshot.data!.docs
                  .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                // Optional: skip completely invalid docs
                if (data[kMessage] == null && data['id'] == null) return null;
                return Message.fromJson(data);
              })
                  .whereType<Message>() // filters out nulls
                  .toList();
              return Scaffold(
                backgroundColor: themeProvider.backgroundColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Image.asset(
                        kLogo,
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Text(
                        'Chat',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: MediaQuery.of(context).textScaler.scale(20),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: themeProvider.textColor,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: themeProvider.textColor),
                      onPressed: () async {
                        final shouldLogout = await _showLogoutDialog(context);
                        if (shouldLogout) {
                          await _performLogout(authService, context);
                        }
                      },
                    ),
                  ],
                  backgroundColor: themeProvider.backgroundColor,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: messagesList.length,
                        itemBuilder: (context, index) =>
                        messagesList[index].id == currentEmail
                            ? CustomBubble(message: messagesList[index])
                            : CustomBubbleForFriends(
                                message: messagesList[index],
                              ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.030,
                      ),
                      child: TextField(
                        style: TextStyle(color: themeProvider.textColor),
                        controller: controller,
                        onSubmitted: (value) {
                          ref.add({
                            kMessage: value,
                            kCreatedAt: DateTime.now(),
                            'id': currentEmail,
                          });
                          controller.clear();
                          _scrollController.jumpTo(0.0,);
                        },
                        decoration: InputDecoration(
                          hintText: 'Send Message',
                          suffixIcon: IconButton(
                            onPressed: () {
                              ref.add({
                                kMessage: controller.text,
                                kCreatedAt: DateTime.now(),
                                'id': currentEmail,
                              });
                              controller.clear();
                              _scrollController.jumpTo(0.0);
                            },
                            icon: Icon(Icons.send),
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.030,
                            ),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _performLogout(
    AuthService authService,
    BuildContext context,
  ) async {
    try {
      await authService.signOut();

      Fluttertoast.showToast(
        msg: 'Logged out successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error logging out: $e',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
