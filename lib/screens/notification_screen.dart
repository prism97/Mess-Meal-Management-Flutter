import 'package:flutter/material.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';

class NotificationScreen extends StatelessWidget {
  static const String id = 'stats_screen';
  final Map<String, dynamic> message;

  const NotificationScreen({@required this.message});

  @override
  Widget build(BuildContext context) {
    print(message);
    return Scaffold(
      appBar: CustomAppBar(title: "Notification"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['title'],
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              message['text'],
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
      ),
    );
  }
}
