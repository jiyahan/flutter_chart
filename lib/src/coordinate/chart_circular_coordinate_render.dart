import 'dart:math';

import 'package:flutter/material.dart';

import '../measure/chart_param.dart';
import 'chart_coordinate_render.dart';
import '../utils/transform_utils.dart';

enum ArcPosition {
  none,
  up,
  down,
}

@Deprecated('instead of  using [ChartCircularCoordinateRender]')
typedef CircularChartCoordinateRender = ChartCircularCoordinateRender;

/// @author JD
/// 圆形坐标系
class ChartCircularCoordinateRender extends ChartCoordinateRender {
  final double borderWidth;
  final Color borderColor;
  final StrokeCap? strokeCap;
  final ArcPosition arcPosition;
  ChartCircularCoordinateRender({
    super.margin = EdgeInsets.zero,
    super.padding = EdgeInsets.zero,
    required super.charts,
    super.safeArea,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    this.arcPosition = ArcPosition.none,
    this.borderWidth = 1,
    this.strokeCap,
    this.borderColor = Colors.white,
  });

  ///半径
  late double radius;

  ///中心点
  late Offset center;

  @override
  void paint(ChartParam param, Canvas canvas, Size size) {
    _drawCircle(param, canvas, size);
    _drawBackgroundAnnotations(param, canvas, size);
    for (var element in charts) {
      element.draw(param, canvas, size);
    }
    _drawForegroundAnnotations(param, canvas, size);
  }

  ///画背景圆
  void _drawCircle(ChartParam param, Canvas canvas, Size size) {
    final sw = size.width - contentMargin.horizontal;
    final sh = size.height - contentMargin.vertical;
    // 定义圆形的绘制属性
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..isAntiAlias = true
      ..strokeWidth = borderWidth;

    if (strokeCap != null) {
      paint.strokeCap = strokeCap!;
    }

    //满圆
    if (arcPosition == ArcPosition.none) {
      // 确定圆的半径
      radius = min(sw, sh) / 2 - borderWidth / 2;
      // 定义中心点
      center = size.center(Offset.zero);
      // 使用 Canvas 的 drawCircle 绘制
      canvas.drawCircle(center, radius, paint);
      transformUtils = TransformUtils(
        anchor: center,
        size: size,
        padding: padding,
        zoomVertical: zoomVertical,
        zoomHorizontal: zoomHorizontal,
        zoom: param.zoom,
        offset: param.offset,
        reverseX: false,
        reverseY: false,
      );
    } else {
      //带有弧度
      double maxSize = max(sw, sh);
      double minSize = min(sw, sh);
      radius = min(maxSize / 2, minSize) - borderWidth / 2;
      center = size.center(Offset.zero);
      double startAngle = 0;
      double sweepAngle = pi;
      if (arcPosition == ArcPosition.up) {
        startAngle = pi;
        center = Offset(center.dx, size.height - contentMargin.bottom);
        transformUtils = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          zoomVertical: zoomVertical,
          zoomHorizontal: zoomHorizontal,
          zoom: param.zoom,
          offset: param.offset,
          reverseX: false,
          reverseY: true,
        );
      } else if (arcPosition == ArcPosition.down) {
        center = Offset(center.dx, contentMargin.top);
        transformUtils = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          zoomVertical: zoomVertical,
          zoomHorizontal: zoomHorizontal,
          zoom: param.zoom,
          offset: param.offset,
          reverseX: false,
          reverseY: false,
        );
      }
      Path path = Path()
        ..addArc(
          Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      canvas.drawPath(path, paint);
    }
  }

  ///背景
  void _drawBackgroundAnnotations(ChartParam param, Canvas canvas, Size size) {
    backgroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw(param, canvas, size);
    });
  }

  ///前景
  void _drawForegroundAnnotations(ChartParam param, Canvas canvas, Size size) {
    foregroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw(param, canvas, size);
    });
  }
}