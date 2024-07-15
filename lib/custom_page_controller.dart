import 'package:flutter/material.dart';

class CustomPageController extends PageController {
  final bool Function() onScrollEnabled;

  CustomPageController({
    required this.onScrollEnabled,
    int initialPage = 0,
  }) : super(initialPage: initialPage);

  @override
  void notifyListeners() {
    if (onScrollEnabled()) {
      super.notifyListeners();
    }
  }
}