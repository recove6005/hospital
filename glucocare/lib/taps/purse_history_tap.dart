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

  // 달력 설정
  Future<void> _searchYearMonth(BuildContext context) async {
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

  // 커스텀 다이얼로그 - 년월 선택
  Future<void> _selectMonthYear() async {
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '년월 선택',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),),
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(30, (index) {
                      int year = 2000 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year 년'),
                      );
                    }),
                    onChanged: (value) {
                      selectedYear = value!;
                    },
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          selectedMonth = index + 1;
                          setState(() {
                            _selectedDate = DateTime(selectedYear, selectedMonth);
                            _focusedDate = _selectedDate;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF9F9F9),
                          ),
                          child: Text('${index + 1}월'),
                        ),
                      );
                    },
                  ),
                ],
              ),

            ),
          );
        }
    );
  }

  // 차트 설정 함수
  final List<String> _shrinkX = [];
  LineChartBarData? _shrinkLine;
  final List<String> _relaxX = [];
  LineChartBarData? _relaxLine;
  double _minX = -0.2;
  double _maxX = 0;
  double _minY = -5;
  double _maxY = 305;

  final buffer = 10.0; // 차트 그래프 여유값
  ScrollController _scrollController = ScrollController();

  String? _chartSelectedValeu = '1주일';
  double _chartSize = 500;

  List<FlSpot> _shrinkData = [];
  List<FlSpot> _relaxData = [];

  Future<void> _setLinesByThirty() async {
    _shrinkData = await PurseRepository.getShrinkDataByThirty(_shrinkX);
    _relaxData = await PurseRepository.getRelaxDataByThirty(_relaxX);
    _maxX = _shrinkData.length.toDouble()+0.2;
    _chartSize = _maxX*50;

    setState(() {
      _shrinkLine = LineChartBarData(
        spots: _shrinkData,
        isCurved: true,
        color: Colors.red[300],
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _relaxLine = LineChartBarData(
        spots: _relaxData,
        isCurved: true,
        color: Colors.green,
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _isChartLoading = false;
    });
  }

  Future<void> _setLinesByNinety() async {
    _shrinkData = await PurseRepository.getShrinkDataByNinety(_shrinkX);
    _relaxData = await PurseRepository.getRelaxDataByNinety(_relaxX);
    _maxX = _shrinkData.length.toDouble()+0.2;
    _chartSize = _maxX*50;

    setState(() {
      _shrinkLine = LineChartBarData(
        spots: _shrinkData,
        isCurved: true,
        color: Colors.red[300],
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _relaxLine = LineChartBarData(
        spots: _relaxData,
        isCurved: true,
        color: Colors.green,
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _isChartLoading = false;
    });
  }

  Future<void> _setLinesBySeven() async {
    _shrinkData = await PurseRepository.getShrinkData(_shrinkX);
    _relaxData = await PurseRepository.getRelaxData(_relaxX);
    _maxX = _shrinkData.length.toDouble()+0.2;
    _chartSize = _maxX*50;

    setState(() {
      _shrinkLine = LineChartBarData(
        spots: _shrinkData,
        isCurved: true,
        color: Colors.red[300],
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _relaxLine = LineChartBarData(
        spots: _relaxData,
        isCurved: true,
        color: Colors.green,
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _isChartLoading = false;
    });
  }

  Future<void> _setLinesByDay() async {
    _shrinkData = await PurseRepository.getShrinkDataByDay(_shrinkX);
    _relaxData = await PurseRepository.getRelaxDataByDay(_relaxX);
    _maxX = _shrinkData.length.toDouble()+0.2;
    _chartSize = _maxX*50;

    setState(() {
      _shrinkLine = LineChartBarData(
        spots: _shrinkData,
        isCurved: true,
        color: Colors.red[300],
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );

      _relaxLine = LineChartBarData(
        spots: _relaxData,
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
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              return Container();
            },
          ),
        )
    );
  }

  @override
  void initState() {
    super.initState();
    _setPurseModels();
    _setLinesBySeven();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading || _isChartLoading) {
      return const Center(child:CircularProgressIndicator());
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width-50,
                    height: 30,
                    child: const Text(
                      '내 혈압 관리',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  // 헤더
                  GestureDetector(
                    onTap: () async {
                      _selectMonthYear();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width-50,
                      child: Row(
                        children: [
                          Text(
                            '${_focusedDate.year}년 ${_focusedDate.month}월',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey,)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  // 요일 헤더
                  SizedBox(
                    width: MediaQuery.of(context).size.width-50,
                    child: Row(
                      children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
                        return Expanded(
                          child: Center(
                              child: Text(day,style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38),)
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width-50,
                height: 60,
                child: TableCalendar(
                  headerVisible: false, // 헤더 숨김
                  daysOfWeekVisible: false, // 요일 표시 숨김
                  firstDay: DateTime.utc(2023,1,1),
                  lastDay: DateTime.utc(2100,12,31),
                  focusedDay: _selectedDate,
                  calendarFormat: CalendarFormat.week, // 주단위 표시
                  calendarStyle: CalendarStyle(
                      outsideDaysVisible: true,
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
                      outsideTextStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: const Color(0xFFDCF9F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF28C2CE),
                            width: 1,
                            style: BorderStyle.solid
                        ),
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFDCF9F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.transparent,
                            width: 1,
                            style: BorderStyle.solid
                        ),
                      ),
                      defaultDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF9F9F9),
                        border: Border.all(
                            color: Colors.transparent,
                            width: 1,
                            style: BorderStyle.solid
                        ),
                      ),
                      outsideDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF9F9F9),
                        border: Border.all(
                            color: Colors.transparent,
                            width: 1,
                            style: BorderStyle.solid
                        ),
                      ),
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
                width: MediaQuery.of(context).size.width-50,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xffff9f9f9),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20,),
                    Column(
                      children: [
                        const SizedBox(height: 10,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width-100,
                          height: 30,
                          child: Text(
                            '${_focusedDate.month}월 ${_focusedDate.day}일',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if(_purseModels.isEmpty)
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          width: 280,
                          child: const Text('혈압 측정 내역이 없습니다.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        if(_purseModels.isNotEmpty)
                        SizedBox(
                          width: MediaQuery.of(context).size.width-100,
                          height: 230,
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
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if(_purseModels[index].checkTime.substring(0,2) == 'AM' ||
                                                        _purseModels[index].checkTime.substring(0,2) == '오전')
                                                      Text('오전 ${_purseModels[index].checkTime.substring(3,8)}',
                                                        style: const TextStyle(
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),),
                                                    if(_purseModels[index].checkTime.substring(0,2) == 'PM' ||
                                                        _purseModels[index].checkTime.substring(0,2) == '오후')
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
                                                      width: MediaQuery.of(context).size.width-100,
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
                        // const SizedBox(height: 20,),
                      ],
                    ),
                  ],
                )
              ),
              const SizedBox(height: 15,),
              Container(
                width: MediaQuery.of(context).size.width-50,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xffff9f9f9),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width-50,
                      height: 30,
                      child: Row(
                        children: [
                          const Text('변화 그래프', style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),),
                          const SizedBox(width: 100,),
                          DropdownButton<String>(
                            value: _chartSelectedValeu,
                            items: <String>['3개월', '1개월', '1주일', '1일']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                // 차트 값 변경
                                _chartSelectedValeu = newValue!;
                                switch(_chartSelectedValeu) {
                                  case '3개월' :
                                    setState(() async {
                                      await _setLinesByNinety();

                                    });
                                  case '1개월' :
                                    setState(() async {
                                      await _setLinesByThirty();
                                      _maxX = _shrinkData.length.toDouble();
                                      _chartSize = _maxX*50;
                                    });
                                  case '1주일' :
                                    setState(() async {
                                      await _setLinesBySeven();
                                      _maxX = _shrinkData.length.toDouble();
                                      _chartSize = _maxX*50;
                                    });
                                    break;
                                  case '1일' :
                                    setState(() async {
                                      await _setLinesByDay();
                                      _maxX = _shrinkData.length.toDouble();
                                      _chartSize = _maxX*50;
                                    });
                                    break;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width-120,
                      height: 200,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: _chartSize,
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              backgroundColor: Colors.red[50],
                              lineBarsData: [_shrinkLine!, _relaxLine!],
                              clipData: const FlClipData.all(), // 모든 방향에서 초과된 부분 클립
                              lineTouchData: const LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  fitInsideVertically: true,
                                  fitInsideHorizontally: true,
                                ),
                              ),
                              titlesData: _buildTitles(),
                              gridData: FlGridData(
                                  show: false,
                                  drawVerticalLine: false,
                                  horizontalInterval: 50,
                                  getDrawingHorizontalLine: (value) {
                                    return const FlLine(
                                      color: Colors.grey,
                                      strokeWidth: 1,
                                    );
                                  }
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(),
                              ),
                              minX: _minX,
                              maxX: _maxX,
                              minY: _minY,
                              maxY: _maxY,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50,),
            ],
          ),
        ),
      ),
    );
  }
}