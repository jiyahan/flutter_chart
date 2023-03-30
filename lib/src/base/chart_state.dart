import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

//数据共享，便于各个节点使用
class ChartState extends ChangeNotifier {
  Offset? _gesturePoint;
  set gesturePoint(value) {
    if (value != _gesturePoint) {
      _gesturePoint = value;
      notifyListeners();
    }
  }

  Offset? get gesturePoint => _gesturePoint;

  double _zoom = 1;
  //缩放
  double get zoom => _zoom;
  set zoom(v) {
    gesturePoint = null;
    _zoom = v;
  }

  //偏移
  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(v) {
    gesturePoint = null;
    _offset = v;
  }

  //根据位置缓存配置信息
  Map<int, CharBodyState> bodyStateList = {};
}

class CharBodyState {
  int? selectedIndex;
  List<ChartShapeState>? shapeList;
}

//存放每条数据对应的绘图信息
class ChartShapeState {
  Rect? rect;
  Path? path;
  ChartShapeState({
    this.rect,
    this.path,
  });
  //前面一个图形的信息 目的为了解决图形之间的关联信息
  ChartShapeState? preShapeState;
  //下一个图形的信息
  ChartShapeState? nextShapeState;
  double? left;
  double? right;
  //某条数据下 可能会有多条数据
  List<ChartShapeState> children = [];

  ChartShapeState.rect({required this.rect});

  ChartShapeState.arc({
    required Offset center, // 中心点
    required double innerRadius, // 小圆半径
    required double outRadius, // 大圆半径
    required double startAngle,
    required double sweepAngle,
  }) {
    rect = null;
    double startRad = startAngle;
    double endRad = startAngle + sweepAngle;

    double r0 = innerRadius;
    double r1 = outRadius;
    Offset p0 = Offset(cos(startRad) * r0, sin(startRad) * r0);
    Offset p1 = Offset(cos(startRad) * r1, sin(startRad) * r1);
    Offset q0 = Offset(cos(endRad) * r0, sin(endRad) * r0);
    Offset q1 = Offset(cos(endRad) * r1, sin(endRad) * r1);

    bool large = sweepAngle.abs() > pi;
    bool clockwise = sweepAngle > 0;

    Path localPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..arcToPoint(q1,
          radius: Radius.circular(r1), clockwise: clockwise, largeArc: large)
      ..lineTo(q0.dx, q0.dy)
      ..arcToPoint(p0,
          radius: Radius.circular(r0), clockwise: !clockwise, largeArc: large);
    path = localPath.shift(center);
  }

  //获取热区
  Rect? getHotRect() {
    //处理前后关联热区
    if (preShapeState == null && nextShapeState == null) {
      //都为空有两种情况
      //1、数据只有一条
      //2、该图不需要处理热区
      if (left != null && right != null) {
        //说明是第一种情况
        return Rect.fromLTRB(left!, rect!.top, right!, rect!.bottom);
      }
      return null;
    } else if (preShapeState == null && nextShapeState != null) {
      //说明是第一个
      ChartShapeState next = nextShapeState!;
      bool reverse = nextShapeState!.rect!.center.dx < rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = next.rect!.right - rect!.left;
        l = rect!.left + diff / 2;
        r = right!;
      } else {
        double diff = next.rect!.left - rect!.right;
        r = rect!.right + diff / 2;
        l = left!;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    } else if (preShapeState != null && nextShapeState == null) {
      //说明是最后一个
      ChartShapeState pre = preShapeState!;
      bool reverse = preShapeState!.rect!.center.dx > rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = rect!.right - pre.rect!.left;
        l = left!;
        r = rect!.right + diff / 2;
      } else {
        double diff = rect!.left - pre.rect!.right;
        l = rect!.left - diff / 2;
        r = right!;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    } else if (preShapeState != null && nextShapeState != null) {
      //说明是中间点
      ChartShapeState next = nextShapeState!;
      ChartShapeState pre = preShapeState!;
      bool reverse = nextShapeState!.rect!.center.dx < rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = rect!.right - pre.rect!.left;
        l = left!;
        r = rect!.right + diff / 2;
      } else {
        double diffLeft = rect!.left - pre.rect!.right;
        double diffRight = next.rect!.left - rect!.right;
        l = rect!.left - diffLeft / 2;
        r = rect!.right + diffRight / 2;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    }
    return null;
  }

  //判断热区是否命中
  bool hitTest(Offset? anchor) {
    if (anchor == null) {
      return false;
    }

    if (rect?.contains(anchor) == true) {
      return true;
    }

    if (path?.contains(anchor) == true) {
      return true;
    }

    Rect? hotRect = getHotRect();
    if (hotRect?.contains(anchor) == true) {
      return true;
    }

    return false;
  }
}
