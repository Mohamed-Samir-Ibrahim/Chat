import 'package:chat_app/core/constant/app_constants.dart';
import 'package:chat_app/core/model/message.dart';
import 'package:chat_app/shared/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBubble extends StatelessWidget {
  const CustomBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.030,
              right: MediaQuery.of(context).size.width * 0.030,
              top: MediaQuery.of(context).size.height * 0.020,
              bottom: MediaQuery.of(context).size.height * 0.020,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.030,
              vertical: MediaQuery.of(context).size.height * 0.010,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  MediaQuery.of(context).size.width *
                      (20 / MediaQuery.of(context).size.width),
                ),
                topRight: Radius.circular(
                  MediaQuery.of(context).size.width *
                      (20 / MediaQuery.of(context).size.width),
                ),
                bottomRight: Radius.circular(
                  MediaQuery.of(context).size.width *
                      (20 / MediaQuery.of(context).size.width),
                ),
              ),
            ),
            child: Text(
              message.message,
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
        );
      },
    );
  }
}

class CustomBubbleForFriends extends StatelessWidget {
  const CustomBubbleForFriends({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.030,
              right: MediaQuery.of(context).size.width * 0.030,
              top: MediaQuery.of(context).size.height * 0.020,
              bottom: MediaQuery.of(context).size.height * 0.020,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.030,
              vertical: MediaQuery.of(context).size.height * 0.010,
            ),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  MediaQuery.of(context).size.width *
                      (20 / MediaQuery.of(context).size.width),
                ),
                topRight: Radius.circular(
                  MediaQuery.of(context).size.width *
                      (20 / MediaQuery.of(context).size.width),
                ),
                bottomLeft: Radius.circular(
                  MediaQuery.of(context).size.width *
                      (20 / MediaQuery.of(context).size.width),
                ),
              ),
            ),
            child: Text(
              message.message,
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
        );
      },
    );
  }
}
