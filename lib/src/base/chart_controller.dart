import 'package:flutter/material.dart';
import '../coordinate/chart_coordinate_render.dart';
import '../param/chart_layout_param.dart';
import '../param/chart_param.dart';

/// @author jd

///数据共享，便于各个节点使用
class ChartController {
  ///
  // WeakReference<ChartCoordinateRender>? _chartCoordinateRender;

  ///通知弹框层刷新
  StateSetter? _tooltipStateSetter;

  ///chart 图形参数
  ChartParam? _param;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> get chartParam => _param?.childrenState ?? [];

  Offset? _tapPosition;
  Offset? get tapPosition => _tapPosition;
  Offset? get localPosition => _param?.localPosition;

  ///重置提示框
  void resetTooltip() {
    bool needNotify = false;
    if (tooltipWidgetBuilder != null) {
      _tooltipWidgetBuilder = null;
      needNotify = true;
    }
    if (_tapPosition != null) {
      _tapPosition = null;
      needNotify = true;
    }
    if (_param?.localPosition != null) {
      _param?.localPosition = null;
      needNotify = true;
    }
    if (needNotify) {
      notifyTooltip();
    }
  }

  AnnotationTooltipWidgetBuilder? _tooltipWidgetBuilder;
  get tooltipWidgetBuilder => _tooltipWidgetBuilder;

  ///使用widget渲染tooltip
  void showTooltipBuilder({required AnnotationTooltipWidgetBuilder builder, required Offset position}) {
    _tooltipWidgetBuilder = builder;
    _tapPosition = position;
    notifyTooltip();
  }
}

extension InnerFuncation on ChartController {
  void attach(ChartCoordinateRender chartCoordinateRender) {
    chartCoordinateRender.controller = this;
    // _chartCoordinateRender = WeakReference(chartCoordinateRender);
  }

  void detach() {
    // _chartCoordinateRender = null;
  }
  void bindParam(ChartParam p) {
    _param = p;
  }

  void bindTooltipStateSetter(StateSetter? stateSetter) {
    _tooltipStateSetter = stateSetter;
  }

  void notifyTooltip() {
    if (_tooltipStateSetter != null) {
      _tooltipStateSetter?.call(() {});
    }
  }
}
