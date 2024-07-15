import 'package:flutter/material.dart';

class AnnotationManager {
  AnnotationManager._privateConstructor();

  static final AnnotationManager _instance =
      AnnotationManager._privateConstructor();

  factory AnnotationManager() {
    return _instance;
  }

  final Map<String, List<Annotation>> _annotations = {};

  List<Annotation> getAllAnnotations() {
    return _annotations.values.expand((annotations) => annotations).toList();
  }

  void addAnnotation(String key, Annotation annotation) {
    if (!_annotations.containsKey(key)) {
      _annotations[key] = [];
    }
    _annotations[key]!.add(annotation);
  }

  Annotation? findAnnotation(
      String key, double offsetX, double offsetY, Size size, bool isText) {
    final annotations = _annotations[key];

    if (annotations != null) {
      for (var annotation in annotations) {
        print("$annotation $offsetX $offsetY $isText");
        if (roundNumber(annotation.offsetX) == roundNumber(offsetX) &&
            roundNumber(annotation.offsetY) == roundNumber(offsetY) &&
            annotation.isText == isText) {
          print(annotation);
          return annotation;
        }
      }
    }
    return null;
  }

  List<Annotation> getAnnotations(String key) {
    return _annotations[key] ?? [];
  }

  double roundNumber(double num) {
    int precision = 2;

    String roundedString = num.toStringAsFixed(precision);
    return double.parse(roundedString);
  }

  Annotation? findAnnotationById(String key, String id) {
    final annotations = _annotations[key];

    if (annotations != null) {
      for (var annotation in annotations) {
        if (annotation.id == id) {
          return annotation;
        }
      }
    }
    return null;
  }

  void removeAnnotation(String key, Annotation annotation) {
    _annotations[key]?.remove(annotation);
  }

  void updateAnnotation(String key, Annotation updatedAnnotation) {
    if (_annotations.containsKey(key)) {
      for (int i = 0; i < _annotations[key]!.length; i++) {
        if (_annotations[key]![i].id == updatedAnnotation.id) {
          if (updatedAnnotation.isText != _annotations[key]![i].isText) {
            updatedAnnotation.isText = _annotations[key]![i].isText;
          }
          _annotations[key]![i] = updatedAnnotation;
          break;
        }
      }
    }
  }
}

class Annotation {
  final String id;
  final String documentPath;
  final int pageIndex;
  Size size;
  double offsetX;
  double offsetY;
  List<String> content;
  bool isText;

  Annotation({
    String? id,
    required this.documentPath,
    required this.pageIndex,
    required this.content,
    required this.size,
    required this.offsetX,
    required this.offsetY,
    required this.isText,
  }) : id = id ?? DateTime.now().toIso8601String();

  @override
  String toString() {
    return 'Annotation{id: $id, documentPath: $documentPath, pageIndex: $pageIndex, size: $size, offsetX: $offsetX, offsetY: $offsetY, content: $content, isText: $isText}';
  }
}
