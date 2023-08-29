import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../flutter_chart.dart';
import '../base/chart_body_render.dart';
import '../base/chart_shape_state.dart';

typedef RadarChartPosition<T> = List<num> Function(T);
typedef RadarValueFormatter<T> = List<dynamic> Function(T);

///雷达图
/// @author JD
class Radar<T> extends ChartBodyRender<T> {
  ///开始的方向
  final RotateDirection direction;

  ///最大值
  final num max;

  ///点的位置
  final RadarChartPosition<T> position;

  ///值文案格式化 不要使用过于耗时的方法
  final RadarValueFormatter? valueFormatter;

  ///基线的颜色
  final Color lineColor;

  ///值的线颜色
  final List<Color> colors;

  ///值的填充颜色
  final List<Color>? fillColors;

  ///图例样式
  final TextStyle legendTextStyle;

  Radar({
    required super.data,
    required this.position,
    required this.max,
    this.lineColor = Colors.black12,
    this.direction = RotateDirection.forward,
    this.valueFormatter,
    this.colors = colors10,
    this.fillColors,
    this.legendTextStyle = const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
  });

  @override
  void draw(Canvas canvas, Size size) {
    CircularChartCoordinateRender chart = coordinateChart as CircularChartCoordinateRender;
    Offset center = chart.center;
    double radius = chart.radius;

    //开始点
    double startAngle = -math.pi / 2;
    int itemLength = data.length;
    double percent = 1 / itemLength;
    List<ChartShapeState> shapeList = [];
    // 计算出每个数据所占的弧度值
    final sweepAngle = percent * math.pi * 2 * (direction == RotateDirection.forward ? 1 : -1);

    // 设置绘制属性
    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..isAntiAlias = true
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    Path linePath = Path();
    Map<int, Path> dataLinePathList = {};
    List<RadarTextPainter> textPainterList = [];
    for (int i = 0; i < itemLength; i++) {
      T itemData = data[i];
      //画边框
      final x = math.cos(startAngle) * radius + center.dx;
      final y = math.sin(startAngle) * radius + center.dy;
      canvas.drawLine(center, Offset(x, y), linePaint);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }

      //画value线
      List<num> pos = position.call(itemData);
      List<dynamic>? legendList = valueFormatter?.call(itemData);
      assert(legendList == null || pos.length == legendList.length);
      for (int j = 0; j < pos.length; j++) {
        Path? dataLinePath = dataLinePathList[j];
        if (dataLinePath == null) {
          dataLinePath = Path();
          dataLinePathList[j] = dataLinePath;
        }
        num subPos = pos[j];
        double vp = subPos / max;
        double newRadius = radius * vp;
        final dataX = math.cos(startAngle) * newRadius + center.dx;
        final dataY = math.sin(startAngle) * newRadius + center.dy;
        if (i == 0) {
          dataLinePath.moveTo(dataX, dataY);
        } else {
          dataLinePath.lineTo(dataX, dataY);
        }

        //画文案
        if (legendList != null) {
          String legend = legendList[j].toString();
          TextPainter legendTextPainter = TextPainter(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: legend,
              style: legendTextStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(
              minWidth: 0,
              maxWidth: chart.size.width,
            );
          bool isLeft = dataX < center.dx;
          Offset textOffset = Offset(isLeft ? (dataX - legendTextPainter.width) : dataX, dataY - legendTextPainter.height);
          //最后再绘制，防止被挡住
          textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
        }
      }

      //继续下一个
      startAngle = startAngle + sweepAngle;
    }
    linePath.close();
    canvas.drawPath(linePath, linePaint);
    //画数据
    int index = 0;
    for (Path dataPath in dataLinePathList.values) {
      dataPath.close();

      // 设置绘制属性
      final dataLinePaint = Paint()
        ..strokeWidth = 1.0
        ..color = colors[index]
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke;
      canvas.drawPath(dataPath, dataLinePaint);

      if (fillColors != null) {
        final fillDataLinePaint = Paint()
          ..color = fillColors![index]
          ..isAntiAlias = true
          ..style = PaintingStyle.fill;
        canvas.drawPath(dataPath, fillDataLinePaint);
      }
      index++;
    }
    //最后再绘制，防止被挡住
    for (RadarTextPainter textPainter in textPainterList) {
      textPainter.textPainter.paint(canvas, textPainter.offset);
    }

    bodyState.shapeList = shapeList;
  }
}

class RadarTextPainter {
  final TextPainter textPainter;
  final Offset offset;
  RadarTextPainter({required this.textPainter, required this.offset});
}