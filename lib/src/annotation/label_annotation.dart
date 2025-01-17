part of flutter_chart_plus;

/// @author jd
class LabelAnnotation extends Annotation {
  ///两个长度的数组，优先级最高，ImageAnnotation的位置，对应xy轴的value
  final List<num>? positions;

  ///文本风格
  final TextStyle textStyle;

  ///对齐方式
  final TextAlign textAlign;

  ///内容
  final String text;

  ///偏移，可以做细微调整
  final Offset offset;

  ///设置Annotation的偏移，忽略positions的设置
  final Offset Function(Size)? anchor;

  LabelAnnotation({
    super.userInfo,
    super.onTap,
    super.scroll = true,
    super.yAxisPosition = 0,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.text,
    this.positions,
    this.anchor,
    this.offset = Offset.zero,
    this.textAlign = TextAlign.start,
    this.textStyle = const TextStyle(color: Colors.red),
  }) : assert(positions != null || anchor != null, 'positions or anchor must be not null');

  TextPainter? _textPainter;

  @override
  void init(ChartParam param) {
    super.init(param);
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: param.size.width,
      );
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    if (!needDraw(param)) {
      return;
    }

    if (param is _ChartDimensionParam) {
      Offset ost;
      if (positions != null) {
        assert(positions!.length == 2, 'positions must be two length');
        num xPo = positions![0];
        num yPo = positions![1];

        double density = 0;
        if (scroll) {
          density = param.xAxis.density;
        } else {
          density = param.xAxis.fixedDensity;
        }
        double itemWidth = xPo * density;
        double itemHeight = param.yAxis[yAxisPosition].relativeHeight(yPo);
        double left = param.transform.transformX(
          itemWidth,
          containPadding: true,
        );
        double top = param.transform.transformY(
          itemHeight,
          containPadding: true,
        );

        if (scroll) {
          left = param.transform.withXOffset(left);
          top = param.transform.withYOffset(top);
        } else {
          //不跟随缩放
          left = param.transform.transformX(
            itemWidth,
            containPadding: true,
          );
          top = param.transform.transformY(
            itemHeight,
            containPadding: true,
          );
        }
        ost = Offset(left, top).translate(offset.dx, offset.dy);
      } else {
        ost = anchor!(param.size);
      }

      if (textAlign == TextAlign.end) {
        ost = ost.translate(-_textPainter!.width, 0);
      } else if (textAlign == TextAlign.center) {
        ost = ost.translate(-_textPainter!.width / 2, 0);
      }
      super.location = ost;
      super.size = _textPainter!.size;
      _textPainter!.paint(canvas, ost);
    }
  }
}
