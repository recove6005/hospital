import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/reservation_model.dart';
import '../../repositories/reservation_repository.dart';

class ScheduleManagementPage extends StatelessWidget {
  final UserModel model;
  const ScheduleManagementPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("환자 예약 관리", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: ScheduleManagementForm(model: model,),
    );
  }
}

class ScheduleManagementForm extends StatefulWidget {
  final UserModel model;
  const ScheduleManagementForm({super.key, required this.model});

  @override
  State<ScheduleManagementForm> createState() => _ScheduleManagementFormState(model: model);
}

class _ScheduleManagementFormState extends State<ScheduleManagementForm> {
  final UserModel model;
  _ScheduleManagementFormState({required this.model});

  Logger logger = Logger();
  bool _isLoading = true;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  bool _isDayEnabled(DateTime day) {
    return !day.isBefore(DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ));
  }

  List<String> _reservationDateStrs = [];
  List<String> _timeStrs = [];
  List<ReservationModel> _reservations = [];
  List<String> _details = [];
  List<String> _subjects = [];
  Future<void> _getCurReservations() async {
    List<ReservationModel> templist = await ReservationRepository.selectAllReservationsBySpecificUid(model.uid);
    List<String> tempStrs = [];
    List<String> tempTimeStrs = [];
    List<String> tempDetails = [];
    List<String> tempSubjects = [];
    for(ReservationModel model in templist) {
      String dateStr = '${DateFormat('yyyyMMdd').format(model.reservationDate.toDate())}';
      String timeStr = '${DateFormat('yyyyMMdd').format(model.reservationDate.toDate())}${DateFormat('a hh:mm').format(model.reservationDate.toDate())}';
      String detailsStr = '${DateFormat('yyyyMMdd').format(model.reservationDate.toDate())}${model.details}';
      String subjectsStr = '${DateFormat('yyyyMMdd').format(model.reservationDate.toDate())}${model.subject}';
      tempStrs.add(dateStr);
      tempTimeStrs.add(timeStr);
      tempDetails.add(detailsStr);
      tempSubjects.add(subjectsStr);
    }
    setState(() {
      _reservations = templist;
      _reservationDateStrs = tempStrs;
      _timeStrs = tempTimeStrs;
      _details = tempDetails;
      _subjects = tempSubjects;
      _isLoading = false;

      _getFocusedDaysReservationTimes();
    });
  }

  bool _isReserved(DateTime day) {
    String focustedDateStr = DateFormat('yyyyMMdd').format(day);
    if(_reservationDateStrs.contains(focustedDateStr)) return true;
    return false;
  }

  List<String> _focusedDayReservationTimes = [];
  List<String> _focusedDayDetails = [];
  List<String> _focusedDaySubjects = [];
  void _getFocusedDaysReservationTimes() {
    logger.d('glucocare_log _focusedReservation');
    List<String> templist = [];
    String dateStr = DateFormat('yyyyMMdd').format(_focusedDay);
    for(String time in _timeStrs) {
      if(time.contains(dateStr)){
        String timeStr = time.substring(8);
        templist.add(timeStr);
      }
    }
    List<String> tempdetails = [];
    for(String detailStrs in _details) {
      if(detailStrs.contains(dateStr)) {
        String detailStr = detailStrs.substring(8);
        tempdetails.add(detailStr);
      }
    }
    List<String> tempSubjects = [];
    for(String subjectStrs in _subjects) {
      if(subjectStrs.contains(dateStr)) {
        String subjectStr = subjectStrs.substring(8);
        tempSubjects.add(subjectStr);
      }
    }

    setState(() {
      _focusedDayReservationTimes = templist;
      _focusedDayDetails = tempdetails;
      _focusedDaySubjects = tempSubjects;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurReservations();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Center(child: CircularProgressIndicator(),);
    return SingleChildScrollView(
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            locale: 'ko_KR',
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2024, 12, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              todayTextStyle: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
            ),
            calendarBuilders: CalendarBuilders(
                todayBuilder: (context, day, focusedDay) {
                  if(_isReserved(day)) {
                    return Center(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.red, size: 15,),
                            Text('${day.day}', style: const TextStyle(color: Colors.lightBlueAccent),)
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Container(
                      width: 80,
                      height: 60,
                      child: Center(
                          child: Text('${day.day}', style: const TextStyle(color: Colors.lightBlueAccent),)
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, day, focusedDay) {
                  if(_isReserved(day)) {
                    return Center(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.red, size: 15,),
                            Text('${day.day}', style: const TextStyle(color: Colors
                                .black),)
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Container(
                      width: 80,
                      height: 60,
                      child: Center(
                          child: Text('${day.day}', style: const TextStyle(color: Colors.black),)
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  if(_isReserved(day)) {
                    return Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.white, size: 15,),
                            Text('${day.day}', style: const TextStyle(color: Colors.white),)
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Text('${day.day}', style: const TextStyle(color: Colors.white),)
                      ),
                    );
                  }
                }
            ),
            pageAnimationEnabled: true,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _getFocusedDaysReservationTimes();
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _getFocusedDaysReservationTimes();
              });
            },
            enabledDayPredicate: _isDayEnabled,
          ),
          const SizedBox(height: 30,),
          Container(
            padding: const EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${_focusedDay.year}년 ${_focusedDay.month}월 ${_focusedDay.day}일', style: const TextStyle(fontSize: 20),),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text('진료 일정', style: TextStyle(fontSize: 18),),
            ),
          ),
          const SizedBox(height: 20,),
          Container(
            width: MediaQuery.of(context).size.width - 30,
            height: 300,
            padding: const EdgeInsets.only(left: 30),
            child: Center(
              child:_focusedDayReservationTimes.isEmpty
                  ? Text('예약된 진료 일정이 없습니다.')
                  : ListView.builder(
                itemCount: _focusedDayReservationTimes.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: Colors.transparent),
                      ),
                    ),
                    child: Card(
                      color: const Color(0xfff9f9f9),
                      child: GestureDetector(
                        onTap: () {
                          // 예약 삭제 - uid, timestamp로 비교
                          String uid = model.uid;
                          DateTime reservation = DateTime(
                            _focusedDay.year,
                            _focusedDay.month,
                            _focusedDay.day,
                          );

                          setState(() {
                            _getFocusedDaysReservationTimes();
                          });
                        },
                        child:  ListTile(
                          title: Align(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_hospital,),
                                const SizedBox(width: 5,),
                                Text(
                                  '[${_focusedDaySubjects[index]}]',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _focusedDayReservationTimes[index],
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                _focusedDayDetails[index],
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          //subtitle:
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 50,),
        ],
      ),
    );
  }
}

