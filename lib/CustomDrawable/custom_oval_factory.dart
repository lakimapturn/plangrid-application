import 'dart:ui';

import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:plangrid/custom_oval_drawable.dart';

/// A [OvalWithCenteredTextDrawable] factory.
class CustomOvalFactory extends ShapeFactory<OvalWithCenteredTextDrawable> {
  final String initialText;

  /// Creates an instance of [OvalFactory].
  CustomOvalFactory({this.initialText = ''}) : super();

  /// Creates and returns a [OvalWithCenteredTextDrawable] of zero size and the passed [position] and [paint].
  @override
  OvalWithCenteredTextDrawable create(Offset position, [Paint? paint]) {
    return OvalWithCenteredTextDrawable(
        size: Size(80, 80),
        position: position,
        paint: paint,
        text: initialText);
  }
}
