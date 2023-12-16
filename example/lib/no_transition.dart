import 'package:flutter/material.dart';

class NoTransitions extends PageTransitionsTheme {
  @override
  Widget buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
      ) {
    return child;
    // return super.buildTransitions(
    //   route,
    //   context,
    //   animation,
    //   secondaryAnimation,
    //   child,
    // );
  }
}