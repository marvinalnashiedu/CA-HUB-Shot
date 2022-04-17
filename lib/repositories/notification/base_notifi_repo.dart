import 'package:cahubshot/models/models.dart';

abstract class BaseNotificationRepo {
  Stream<List<Future<NotificationModel>>> getUserNotifications({String userId});
}
