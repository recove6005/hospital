import 'package:background_fetch/background_fetch.dart';
import 'package:glucocare/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FetchService {
  static Logger logger = Logger();

  // Headless Init 실행 작업 함수
  @pragma('vm:entry-point')
  static Future<void> _executeFetchTask(HeadlessTask task) async {
    String taskId = task.taskId;
    logger.d('[glucocare_log] task startd. taskId: $taskId');
    try {
      if(taskId.toString().contains('first')) {
        await NotificationService.showNotification();

        String secondTaskId = taskId.toString().substring(5);

        await BackgroundFetch.scheduleTask(TaskConfig(
          taskId: secondTaskId,
          periodic: true,
          delay: 1000,
          // delay: 86400000,
          stopOnTerminate: false,
          enableHeadless: true,
          forceAlarmManager: true,
        ),);
      } else {
        await NotificationService.showNotification();
      }

    } catch (e) {
      logger.d("[glucocare_log] Error: $e");
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }

  static void headlessInit() async {
    // 헤드리스 작업 등록 (앱 종료 상태에서 실행 가능)
    BackgroundFetch.registerHeadlessTask(_executeFetchTask);
    logger.d('[glucocare_log] Headless Init..');
  }

  static Future<void> initConfigureBackgroundFetch() async {
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: true,
      ),
          (taskId) async {
        try {
          if(taskId.toString().contains('first')) {
            await NotificationService.showNotification();

            String secondTaskId = taskId.toString().substring(5);

            await BackgroundFetch.scheduleTask(TaskConfig(
              taskId: secondTaskId,
              periodic: true,
              delay: 86400000,
              stopOnTerminate: false,
              enableHeadless: true,
              forceAlarmManager: true,
            ),);
          }
          else {
            await NotificationService.showNotification();
            logger.d('[glucocare_log] The second fetch task excuted.');
          }
        } catch (e) {
          logger.e("[glucocare_log] BackgroundFetchConfig Error: $e");
        } finally {
          BackgroundFetch.finish(taskId);
        }
      },
          (String taskId) async {
        logger.e("[glucocare_log] Task failed: $taskId");
        BackgroundFetch.finish(taskId);
      },
    );
  }

  static Future<void> initScheduleBackgroundFetch(String taskId) async {
    DateTime nowDatetime = DateTime.now();
    DateTime alarmDateTimeStr = DateFormat("HH:mm").parse(taskId);
    DateTime alarmDateTime = DateTime(
        nowDatetime.year,
        nowDatetime.month,
        nowDatetime.day,
        alarmDateTimeStr.hour,
        alarmDateTimeStr.minute
    );

    if(alarmDateTime.isAfter(nowDatetime)) {
      Duration differTime = alarmDateTime.difference(nowDatetime);
      await BackgroundFetch.scheduleTask(TaskConfig(
        taskId: 'first$taskId',
        periodic: false,
        delay: differTime.inMilliseconds,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: true,
      ),);
    } else {
      DateTime tomorrow24 = alarmDateTime.add(const Duration(hours: 24));
      Duration differTime = tomorrow24.difference(nowDatetime);

      await BackgroundFetch.scheduleTask(TaskConfig(
        taskId: 'first$taskId',
        periodic: false,
        delay: differTime.inMilliseconds,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: true,
      ),);
    }
  }

  // 작업 일괄 중지
  static Future<void> stopAllBackgroundFetch() async {
    await BackgroundFetch.stop();
  }

  // 특정 작업 중지
  static Future<void> stopBackgroundFetchByTaskId(String taskId) async {
    await BackgroundFetch.stop(taskId);
  }
}