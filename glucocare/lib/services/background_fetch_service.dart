import 'package:background_fetch/background_fetch.dart';
import 'package:glucocare/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FetchService {
  static Logger logger = Logger();

  static Future<void> trigTask(String taskId) async {
    int intervalMilliSec = 0;

    DateTime now = DateTime.now();
    DateTime parsedTime = DateFormat("HH:mm").parse(taskId);
    DateTime firstTask = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
    intervalMilliSec = firstTask.difference(now).inMilliseconds;
    logger.d('[glucocare_log] task will be started in $firstTask $intervalMilliSec');
  }

  static Future<void> initConfigureBackgroundFetch() async {
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 1,
          stopOnTerminate: false,
          enableHeadless: true,
          forceAlarmManager: true,
        ),
            (taskId) async {
          logger.d('[glucocare_log] init main background fatch.');
          NotificationService.showNotification();
        });
    }

  static Future<void> initScheduleBackgroundFetch(String taskId) async {
    await BackgroundFetch.scheduleTask(TaskConfig(
      taskId: taskId, //'first_${taskId}',
      periodic: true,
      delay: 60000,
      stopOnTerminate: false,
      enableHeadless: true,
      forceAlarmManager: true,
    ));
  }

  // 실행할 작업 함수
  @pragma('vm:entry-point')
  static Future<void> _executeFetchTask(String taskId) async {
    logger.d('[glucocare_log] task startd.');
    try {
      await NotificationService.showNotification();
    } catch (e) {
      logger.d("[glucocare_log] Error: $e");
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }

  // 작업 일괄 중지
  static Future<void> stopBackgroundFetch() async {
    await BackgroundFetch.stop();
  }

  // 특정 작업 중지
  static Future<void> stopBackgroundFetchByTaskId(String taskId) async {
    await BackgroundFetch.stop(taskId);
  }

  static void headlessInit() async {
    // 헤드리스 작업 등록 (앱 종료 상태에서 실행 가능)
    BackgroundFetch.registerHeadlessTask(_executeFetchTask);
  }
}