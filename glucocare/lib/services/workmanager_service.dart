import 'package:flutter/cupertino.dart';
import 'package:glucocare/services/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerService {
  static Logger logger = Logger();

  @pragma('vm:entry-point')
  static void callbackDispatcher() async {
    Workmanager().executeTask((task, inputData) async {
      // Flutter Local Notification 호출
      // WorkManager가 비동기 작업에서 필요한 초기화
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await NotificationService.showNotification();
        return Future.value(true); // 성공 반환
      } catch (e) {
        logger.e('[glucocare_log] Error in NotificationService: $e');
        return Future.value(false); // 실패 반환
      }
    });
  }

  static void addPeriodicWork() {
    try {
      Workmanager().registerPeriodicTask(
        'task001_id',
        'task001_name',
        frequency: const Duration(minutes: 16),
      );
    } catch(e) {
      logger.d('[glucocare_log] Failed to add task : $e');
    }
  }

  static void deleteAllTasks() async {
    await Workmanager().cancelAll();
  }
}