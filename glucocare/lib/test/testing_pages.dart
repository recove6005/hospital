import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../repositories/purse_repository.dart';

void main() {
  runApp(MyTestApp());
}

class MyTestApp extends StatelessWidget {
  List<String> _shrinkX = [];
  LineChartBarData _shrinkLine = LineChartBarData();
  List<String> _relaxX = [];
  LineChartBarData _relaxLine = LineChartBarData();

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: _getLines(),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 30,
        minY: 0,
        maxY: 150,
      ),
    );
  }

  Future<void> _setLines() async {
    _shrinkLine = LineChartBarData(
        spots: await PurseRepository.getShrinkData(_shrinkX),
        isCurved: true,
        color: Colors.red,
        barWidth: 2,
        dotData: const FlDotData(show: true)
    );

    _relaxLine = LineChartBarData(
        spots: await PurseRepository.getRelaxData(_relaxX),
        isCurved: true,
        color: Colors.yellow,
        barWidth: 2,
        dotData: const FlDotData(show: true)
    );

  }

  List<LineChartBarData> _getLines() {
    _setLines();
    List<LineChartBarData> lines = [_shrinkLine, _relaxLine];
    return lines;
  }
}