import 'package:glucocare/services/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerService {
  static Logger logger = Logger();

  @pragma('vm:entry-point')
  static void callbackDispatcher() async {
    Workmanager().executeTask((task, inputData) async {
      // Flutter Local Notification 호출
      if(task == 'periodicTask') {
        try{
          // await NotificationService.showNotification();
          NotificationService.showNotification();
          return Future.value(true);
        } catch(e) {
          return Future.value(false); // 실패 반환
        }
      } else {
        return Future.value(false);
      }
    });
  }

  static void addPeriodicWork() {
    try {
      Workmanager().registerPeriodicTask(
        'pillAlarmTaskId',
        'periodicTask',
        frequency: const Duration(hours: 1),
      );
      logger.d('[glucocare_log] task added.');

    } catch(e) {
      logger.d('[glucocare_log] Failed to add task : $e');
    }
  }

  static void deleteAllTasks() async {
    await Workmanager().cancelAll();
  }
}