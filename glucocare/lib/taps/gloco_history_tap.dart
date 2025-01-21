import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:table_calendar/table_calendar.dart';

class GlucoHistoryTap extends StatelessWidget {
  const GlucoHistoryTap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GlucoHistoryForm(),
    );
  }
}

class GlucoHistoryForm extends StatefulWidget {
  const GlucoHistoryForm({super.key});

  @override
  dynamic noSuchMethod(Invocation invocation) => _GlucoHistoryForm();
}

class _GlucoHistoryForm extends State<GlucoHistoryForm> {
  Logger logger = Logger();
  bool _isLoading = true;
  bool _isChartLoading = true;

  // 히스토리 설정
  List<GlucoModel> _glucoModels = [];
  int _childCount = 0;

  String _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now().toLocal());
  DateTime _selectedDate = DateTime.now().toLocal();
  DateTime _focusedDate = DateTime.now().toLocal();

  void _setGlucoModels() async {
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate);

    try {
      List<GlucoModel> models = await GlucoRepository.selectGlucoByDay(_checkDate);

      setState(() {
        _glucoModels = models;
        _childCount = _glucoModels.length;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('[glucocare_log] Failed to load gluco histories : $e');
    }
  }

  // 달력 설정
  Future<void> _searchYearMonth(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _focusedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
            data: ThemeData.light().copyWith(
              dialogBackgroundColor: const Color(0xFFF9F9F9), // 팝업 배경 색상
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1FA1AA), // 팝업 선택된 항목 색상
                onSurface: Colors.black, // 팝업 텍스트 색상
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                bodySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            child: child!,
        );
      }
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

  // 차트 설정
  final List<String> _glucoX = [];
  LineChartBarData? _glucoLine;
  final double _minX = 0;
  double _maxX = 21;
  final double _minY = 0;
  final double _maxY = 300;

  final buffer = 10.0;

  String? _chartSelectedValeu = '1주일';
  double _chartSize = 500;

  Future<void> _setLines() async {
    List<FlSpot> glucoData = await GlucoRepository.getGlucoData(_glucoX);

    setState(() {
      _glucoLine = LineChartBarData(
        spots: glucoData,
        isCurved: true,
        color: Colors.orange,
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
          showTitles: true,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            int index = value.toInt();
            if (index >= 0 && index < _glucoX.length) {
              return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Transform.rotate(
                    angle: 0,
                    child: Text(_glucoX[index], style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),),
                  ),
                );
              }
            else {
              return Container();
            }
          }
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _setGlucoModels();
    _setLines();
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
                      '내 혈당 관리',
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
                      _focusedDate = focustedDay;
                      _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate);
                      _setGlucoModels();
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
                          if(_glucoModels.isEmpty)
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: 280,
                            child: const Text('혈당 측정 내역이 없습니다.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          if(_glucoModels.isNotEmpty)
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
                                                      if(
                                                      _glucoModels[index].checkTime.substring(0,2) == 'AM' ||
                                                          _glucoModels[index].checkTime.substring(0,2) == '오전'
                                                      )
                                                        Text('오전 ${_glucoModels[index].checkTime.substring(3,8)}',
                                                          style: const TextStyle(
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),),
                                                      if(
                                                      _glucoModels[index].checkTime.substring(0,2) == 'PM' ||
                                                          _glucoModels[index].checkTime.substring(0,2) == '오후'
                                                      )
                                                        Text('오후 ${_glucoModels[index].checkTime.substring(3,8)} ${_glucoModels[index].checkTimeName}',
                                                          style: const TextStyle(
                                                            fontSize: 19,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),),
                                                      Text('${_glucoModels[index].value} mg/dL',
                                                        style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),),
                                                      if(_glucoModels[index].state != '')
                                                        Text(_glucoModels[index].state,
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
                Container( // 차트 위젯
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
                                      _maxX = 270;
                                      _chartSize = _maxX*50;
                                      break;
                                    case '1개월' :
                                      _maxX = 90;
                                      _chartSize = _maxX*50;
                                      break;
                                    case '1주일' :
                                      _maxX = 21;
                                      _chartSize = _maxX*50;
                                      break;
                                    case '1일' :
                                      _maxX = 4;
                                      _chartSize = _maxX*100;
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
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: _chartSize,
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [_glucoLine!],
                                clipData: const FlClipData.all(),
                                lineTouchData: const LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    fitInsideVertically: true,
                                    fitInsideHorizontally: true,
                                  ),
                                ),
                                titlesData: _buildTitles(),
                                gridData: FlGridData(
                                    show: true,
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
                                  border: const Border(
                                    top: BorderSide(
                                      color: Colors.grey,
                                      width: 0.5,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                minX: _minX+buffer,
                                maxX: _maxX,
                                minY: _minY-buffer,
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