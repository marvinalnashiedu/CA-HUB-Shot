import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/blocs/blocs.dart';
import 'package:cahubshot/widgets/centered_text.dart';
import 'package:cahubshot/widgets/widgets.dart';

import 'widgets/notifications.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, notificationState) {
          switch (notificationState.status) {
            case NotificationStatus.error:
              return CenteredText(text: notificationState.failure.message);
            case NotificationStatus.loaded:
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 60),
                itemCount: notificationState.notificationList.length,
                itemBuilder: (context, index) {
                  final notificationModel = notificationState.notificationList[index];
                  return Notifications(notificationModel: notificationModel);
                },
              );

            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
