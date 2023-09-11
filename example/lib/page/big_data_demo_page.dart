import 'dart:math';

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class BigDataChartDemoPage extends StatefulWidget {
  BigDataChartDemoPage({Key? key}) : super(key: key);

  @override
  State<BigDataChartDemoPage> createState() => _BigDataChartDemoPageState();
}

class _BigDataChartDemoPageState extends State<BigDataChartDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);
  List<Map> dataList = [];
  int diffDay = 0;
  @override
  void initState() {
    super.initState();
    _changeData();
  }

  void _changeData() {
    double v = Random().nextInt(10) / 10;
    diffDay = 100000;
    dataList.clear();
    for (int i = 0; i < diffDay; i++) {
      dataList.add({
        'time': startTime.add(Duration(days: 1 + i)),
        'value1': 100 * v + i % 100,
        'value2': 200 * v + i % 100,
        'value3': 300 * v + i % 100,
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
        actions: [
          TextButton(
            onPressed: () {
              _changeData();
            },
            child: const Text(
              '改变数据',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                const Text('Line'),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      animationDuration: const Duration(milliseconds: 500),
                      yAxis: [
                        YAxis(
                          min: 0,
                          max: 500,
                          drawGrid: true,
                        )
                      ],
                      xAxis: XAxis(
                        count: 9,
                        max: diffDay,
                        zoom: true,
                        drawGrid: true,
                        drawLine: true,
                        drawDivider: true,
                        formatter: (index) => '$index',
                      ),
                      charts: [
                        Line(
                          data: dataList,
                          position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                          values: (item) => [
                            item['value1'] as num,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}