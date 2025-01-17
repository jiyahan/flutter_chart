part of flutter_chart_plus;

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
    super.outDraw,
    super.animationDuration,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    this.arcPosition = ArcPosition.none,
    this.borderWidth = 1,
    this.strokeCap,
    this.borderColor = Colors.white,
  });

  // 定义圆形的绘制属性
  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = borderColor
    ..isAntiAlias = true
    ..strokeWidth = borderWidth;

  @override
  void paint(Canvas canvas, ChartParam param) {
    param as _ChartCircularParam;
    _drawCircle(param, canvas);
    _drawBackgroundAnnotations(param, canvas);
    var index = 0;
    for (var element in charts) {
      element.indexAtChart = index;
      element.controller = controller;
      if (!element.isInit) {
        element.init(param);
      }
      element.draw(canvas, param);
      index++;
    }
    _drawForegroundAnnotations(param, canvas);
  }

  @override
  bool canZoom() {
    return false;
  }

  ///画背景圆
  void _drawCircle(_ChartCircularParam param, Canvas canvas) {
    if (strokeCap != null) {
      _paint.strokeCap = strokeCap!;
    }
    //满圆
    if (arcPosition == ArcPosition.none) {
      // 使用 Canvas 的 drawCircle 绘制
      canvas.drawCircle(param.center, param.radius, _paint);
    } else {
      double startAngle = 0;
      double sweepAngle = math.pi;
      if (arcPosition == ArcPosition.up) {
        startAngle = math.pi;
      }
      Path path = Path()
        ..addArc(
          Rect.fromCenter(
            center: param.center,
            width: param.radius * 2,
            height: param.radius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      canvas.drawPath(path, _paint);
    }
  }

  ///背景
  void _drawBackgroundAnnotations(ChartParam param, Canvas canvas) {
    backgroundAnnotations?.forEach((element) {
      if (!element.isInit) {
        element.init(param);
      }
      element.draw(canvas, param);
    });
  }

  ///前景
  void _drawForegroundAnnotations(ChartParam param, Canvas canvas) {
    foregroundAnnotations?.forEach((element) {
      if (!element.isInit) {
        element.init(param);
      }
      element.draw(canvas, param);
    });
  }
}
