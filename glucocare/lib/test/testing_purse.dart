import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../models/purse_model.dart';

class PurseHistoryTap extends StatelessWidget {
  const PurseHistoryTap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PurseHistoryForm(),
    );
  }
}

class PurseHistoryForm extends StatefulWidget {
  const PurseHistoryForm({super.key});

  @override
  dynamic noSuchMethod(Invocation invocation) => _PurseHistoryForm();
}

class _PurseHistoryForm extends State<PurseHistoryForm> {
  Logger logger = Logger();
  bool _isLoading = true;
  bool _isChartLoading = true;

  // 히스토리 내역 설정 함수
  List<PurseModel> _purseModels = [];
  int _childCount = 0;
  DateTime _selectedDate = DateTime.now().toLocal();
  DateTime _focusedDate = DateTime.now().toLocal();
  String _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now().toLocal());

  void _setPurseModels() async {
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate);

    try {
      List<PurseModel> models = await PurseRepository.selectPurseByDay(_checkDate);

      setState(() {
        _purseModels = models;
        _childCount = _purseModels.length;
        _isLoading = false;
      });
    } catch(e) {
      logger.e('[glucocare_log] Failed to load purse check list $e');
    }
  }

  // 달력 설정 함수
  Future<void> _searchYearMonth(BuildContext context) async {
    logger.e('[glucocare_log] tap $e');

    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _focusedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );

    if(picked != null && picked != _focusedDate) {
      setState(() {
        _focusedDate = picked;
        _selectedDate = picked;
      });
    }
  }

  // 차트 설정 함수
  final List<String> _shrinkX = [];
  LineChartBarData? _shrinkLine;
  final List<String> _relaxX = [];
  LineChartBarData? _relaxLine;
  final double _minX = 0;
  final double _maxX = 30;
  final double _minY = 50;
  final double _maxY = 150;

  Future<void> _setLines() async {
    List<FlSpot> shrinkData = await PurseRepository.getShrinkData(_shrinkX);
    List<FlSpot> relaxData = await PurseRepository.getRelaxData(_relaxX);

    setState(() {
      _shrinkLine = LineChartBarData(
        spots: shrinkData,
        isCurved: true,
        color: Colors.red[300],
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _relaxLine = LineChartBarData(
        spots: relaxData,
        isCurved: true,
        color: Colors.green,
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _isChartLoading = false;
    });
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              interval: 50, // 간격 설정
              reservedSize: 40, // 그래프와의 마진 거리 조정 (기본 40)
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 20,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    softWrap: false, // 줄바꿈X
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                  ),
                );
              }
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              if(index>= 0 && index < _shrinkX.length) {
                if(index != 0 && _shrinkX[index-1] == _shrinkX[index]) {
                  return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: const Text(''));
                } else {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Transform.rotate(
                      angle: 0,
                      child: Text(_shrinkX[index], style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      ),
                    ),
                  );
                }
              }
              else {
                return Container();
              }
            },
          ),
        )
    );
  }

  @override
  void initState() {
    super.initState();
    _setPurseModels();
    _setLines();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading || _isChartLoading) {
      return const Center(child:CircularProgressIndicator());
    }
    if(_purseModels.isEmpty) {
      return Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Column(
                children: [
                  // 헤더
                  GestureDetector(
                    onTap: () async {
                      // 년월 선택 다이얼로그 호출
                      _searchYearMonth(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          const SizedBox(width: 30,),
                          Text(
                            '${_focusedDate.year}년 ${_focusedDate.month}월',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black,)
                        ],
                      ),
                    ),
                  ),
                  // 요일 헤더
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
                        return Expanded(
                          child: Center(
                              child: Text(day,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
                child: TableCalendar(
                  headerVisible: false, // 헤더 숨김
                  daysOfWeekVisible: false, // 요일 표시 숨김
                  calendarStyle: CalendarStyle(
                    // cellMargin: EdgeInsets.all(5),
                    // cellPadding: EdgeInsets.all(0),
                      selectedTextStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      todayTextStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      defaultTextStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black
                      ),
                      selectedDecoration: BoxDecoration(
                        color: const Color(0xFF6EC6D3),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF1FA1AA),
                            width: 2,
                            style: BorderStyle.solid
                        ),
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFC2F4F4),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.transparent,
                            width: 1,
                            style: BorderStyle.solid
                        ),
                      ),
                      defaultDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: Colors.transparent,
                            width: 1,
                            style: BorderStyle.solid
                        ),
                      )
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle( //
                      weekdayStyle: const TextStyle(
                        fontSize: 20,
                      ),
                      weekendStyle: const TextStyle(
                        fontSize: 20,
                      ),
                      decoration: BoxDecoration(
                        // colors: -> 배경색
                        borderRadius: BorderRadius.circular(8),
                      )
                  ),
                  firstDay: DateTime.utc(2023,1,1),
                  lastDay: DateTime.utc(2100,12,31),
                  focusedDay: _selectedDate,
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focustedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate);

                      _setPurseModels();
                    });
                  },
                ),
              ),
              const SizedBox(height: 30,),
              Column(
                children: [
                  const SizedBox(
                    width: 350,
                    height: 305,
                    child: Text('혈압 측정 내역이 없습니다.'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 20, top: 30, bottom: 20),
                    width: 350,
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [_shrinkLine!, _relaxLine!],
                        titlesData: _buildTitles(),
                        gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10,
                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                color: Colors.black54,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            }
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            top: BorderSide(
                              color: Colors.black54,
                              width: 2,
                            ),
                            bottom: BorderSide(
                                color: Colors.black54,
                                width: 2
                            ),
                          ),
                        ),
                        minX: _minX,
                        maxX: _maxX,
                        minY: _minY,
                        maxY: _maxY,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Column(
                  children: [
                    // 헤더
                    GestureDetector(
                      onTap: () async {
                        // 년월 선택 다이얼로그 호출
                        _searchYearMonth(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            const SizedBox(width: 30,),
                            Text(
                              '${_focusedDate.year}년 ${_focusedDate.month}월',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.black,)
                          ],
                        ),
                      ),
                    ),
                    // 요일 헤더
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
                          return Expanded(
                            child: Center(
                                child: Text(day,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                  child: TableCalendar(
                    headerVisible: false, // 헤더 숨김
                    daysOfWeekVisible: false, // 요일 표시 숨김
                    calendarStyle: CalendarStyle(
                      // cellMargin: EdgeInsets.all(5),
                      // cellPadding: EdgeInsets.all(0),
                        selectedTextStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        todayTextStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        defaultTextStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black
                        ),
                        selectedDecoration: BoxDecoration(
                          color: const Color(0xFF6EC6D3),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1FA1AA),
                              width: 2,
                              style: BorderStyle.solid
                          ),
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFFC2F4F4),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.transparent,
                              width: 1,
                              style: BorderStyle.solid
                          ),
                        ),
                        defaultDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                              color: Colors.transparent,
                              width: 1,
                              style: BorderStyle.solid
                          ),
                        )
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle( //
                        weekdayStyle: const TextStyle(
                          fontSize: 20,
                        ),
                        weekendStyle: const TextStyle(
                          fontSize: 20,
                        ),
                        decoration: BoxDecoration(
                          // colors: -> 배경색
                          borderRadius: BorderRadius.circular(8),
                        )
                    ),
                    firstDay: DateTime.utc(2023,1,1),
                    lastDay: DateTime.utc(2100,12,31),
                    focusedDay: _selectedDate,
                    calendarFormat: CalendarFormat.week,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDate, day);
                    },
                    onDaySelected: (selectedDay, focustedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate);

                        _setPurseModels();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                    width: 350,
                    height: 305,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20,),
                        Column(
                          children: [
                            const SizedBox(height: 10,),
                            const SizedBox(
                              width: 300,
                              height: 35,
                              child: Text('오늘의 혈압', style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),),
                            ),
                            SizedBox(
                              width: 300,
                              height: 250,
                              child: CustomScrollView(
                                slivers: [
                                  SliverList(delegate: SliverChildBuilderDelegate(
                                      childCount: _childCount,
                                          (context, index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if(_purseModels[index].checkTime.substring(0,2) == 'AM')
                                                      Text('오전 ${_purseModels[index].checkTime.substring(3,8)}',
                                                        style: const TextStyle(
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),),
                                                    if(_purseModels[index].checkTime.substring(0,2) == 'PM')
                                                      Text('오후 ${_purseModels[index].checkTime.substring(3,8)}',
                                                        style: const TextStyle(
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),),
                                                    Text('${_purseModels[index].shrink}/${_purseModels[index].relax} mmHg  |  ${_purseModels[index].purse}회/1분',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),),
                                                    if(_purseModels[index].state != '')
                                                      Text(_purseModels[index].state,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    const SizedBox(height: 10,),
                                                    Container(
                                                      width: 350,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            width: 1,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                  ),),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                          ],
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.only(left: 15, right: 20, top: 30, bottom: 20),
                  width: 350,
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [_shrinkLine!, _relaxLine!],
                      titlesData: _buildTitles(),
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Colors.black54,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          }
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          top: BorderSide(
                            color: Colors.black54,
                            width: 2,
                          ),
                          bottom: BorderSide(
                              color: Colors.black54,
                              width: 2
                          ),
                        ),
                      ),
                      minX: _minX,
                      maxX: _maxX,
                      minY: _minY,
                      maxY: _maxY,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
