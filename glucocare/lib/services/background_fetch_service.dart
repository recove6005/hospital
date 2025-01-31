import 'package:background_fetch/background_fetch.dart';
import 'package:glucocare/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FetchService {
  static Logger logger = Logger();
  static Future<void> initConfigureBackgroundFetch() async {
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: true,
        startOnBoot: true,
      ),
      onFetch,
      onError,
    );
  }

  // 커스텀 태스크 등록
  // first를 포함한 id 생성, 알림 첫 실행
  // 복약 알림 등록 시 실행할 함수
  static Future<void> createFirstAlarmId(String taskId) async {
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
        startOnBoot: true,
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
        startOnBoot: true,
      ),);
    }
  }

  // 복약 알림 패치 로직
  // 첫번째 알림이 실행 후 종료되면, 태스크ID 재생성 후 2번째 알림 등록
  // 두번째 알림부터는 24시간 반복
  static Future<void> onFetch(String taskId) async {
      if(taskId == "flutter_background_fetch") {
        // 메인 태스크

      } else {
        // 커스텀 테스크
        if(taskId.toString().contains('first')) {
          // 첫번째 알림
          await NotificationService.showNotification();
          String secondTaskId = taskId.toString().substring(5);

          // 이후 알림 등록
          await BackgroundFetch.scheduleTask(TaskConfig(
            taskId: secondTaskId,
            periodic: true,
            delay: 86400000,
            stopOnTerminate: false,
            enableHeadless: true,
            forceAlarmManager: true,
            startOnBoot: true,
          ),);
        }
        else {
          // 첫번째 이후 알림
          await NotificationService.showNotification();
        }
      }

    BackgroundFetch.finish(taskId);
  }

  // 해드리스 작업
  @pragma('vm:entry-point')
  static Future<void> _executeFetchTask(HeadlessTask task) async {
    String taskId = task.taskId;
    onFetch(taskId);
  }

  static void headlessInit() async {
    BackgroundFetch.registerHeadlessTask(_executeFetchTask);
  }

  // 에러 핸들링
  static void onError(String taskId) {
    logger.d("Background Fetch Error - taskId: $taskId");
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