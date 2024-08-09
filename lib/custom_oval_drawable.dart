import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:plangrid/CustomDrawable/sized2ddrawable.dart';

/// A drawable of an oval with centered text.
class OvalWithCenteredTextDrawable extends Sized2DDrawable
    implements ShapeDrawable {
  /// The paint to be used for the oval drawable.
  @override
  Paint paint;

  /// The text to be displayed in the center of the oval.
  String text;

  /// The style to be used for the text.
  TextStyle? textStyle;

  final TextPainter textPainter;

  /// Creates a new [OvalWithCenteredTextDrawable] with the given [size], [paint], [text], and [textStyle].
  OvalWithCenteredTextDrawable({
    Paint? paint,
    required Size size,
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    this.text = "",
    this.textStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red,
      fontSize: 18,
    ),
  })  : paint = paint ?? ShapeDrawable.defaultPaint,
        textPainter = TextPainter(text: TextSpan(text: text, style: textStyle),
          textAlign: TextAlign.center,
          textScaleFactor: scale,
          textDirection: TextDirection.ltr,),
        super(
            size: size,
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            locked: locked,
            hidden: hidden);

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the oval and the text on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final drawingSize = this.size * scale;

// Draw the oval
    canvas.drawOval(
        Rect.fromCenter(
            center: position,
            width: drawingSize.width,
            height: drawingSize.height),
        paint);

// Prepare the text painter
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );

// Layout the text
    textPainter.layout(maxWidth: drawingSize.width - 10);

// Calculate the offset to center the text in the oval
    final textOffset = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

// Draw the text
    textPainter.paint(canvas, textOffset);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  OvalWithCenteredTextDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
    String? text,
    TextStyle? textStyle,
  }) {
    return OvalWithCenteredTextDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      size: size ?? this.size,
      locked: locked ?? this.locked,
      paint: paint ?? this.paint,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final size = super.getSize();
    return Size(size.width, size.height);
  }

  void updateText(String newText) {
    text = newText;
    textPainter.text = TextSpan(text: text, style: textStyle);
  }

  /// Compares two [OvalWithCenteredTextDrawable]s for equality.
  @override
  bool operator ==(Object other) {
    return other is OvalWithCenteredTextDrawable &&
        super == other &&
        other.paint == paint &&
        other.size == size &&
        other.text == text &&
        other.textStyle == textStyle;
  }

  @override
  int get hashCode => hashValues(
      hidden,
      locked,
      hashList(assists),
      hashList(assistPaints.entries),
      position,
      rotationAngle,
      scale,
      paint,
      size,
      text,
      textStyle);
}
