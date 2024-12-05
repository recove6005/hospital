import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Logger logger = Logger();

  static Future<void> requestNotificationPermissions() async {
    if (await Permission.notification.isDenied) {
    await Permission.notification.request();
    }
  }

  static Future<void> requestExactAlarmPermission() async {
    // await const MethodChannel('flutter_local_notifications').invokeMethod('requestExactAlarmPermission');
    // logger.e('requested to permit exax');

    // const platform = MethodChannel('flutter_local_notifications');
    // //try {
    //   final result = await platform.invokeMethod('requestExactAlarmPermission');
    //   if (result == true) {
    //     logger.d('Exact Alarm Permission Granted');
    //   } else {
    //     logger.d('Exact Alarm Permission Denied');
    //   }
    // //} catch (e) {
    // //  logger.d('Failed to request exact alarm permission: $e');
    // //}
  }
}