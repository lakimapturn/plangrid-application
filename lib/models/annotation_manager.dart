import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:plangrid/models/annotation_data.dart';

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

  Annotation? findAnnotation(String key, ObjectDrawable drawable) {
    final annotations = _annotations[key];

    if (annotations != null) {
      for (var annotation in annotations) {
        if (annotation.drawable == drawable) {
          return annotation;
        }
      }
    }
    return null;
  }

  List<Annotation> getAnnotations(String key) {
    return _annotations[key] ?? [];
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
        if (_annotations[key]![i].id == updatedAnnotation.id &&
            _annotations[key]![i].drawable.runtimeType ==
                updatedAnnotation.drawable.runtimeType) {
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
  ObjectDrawable drawable;
  AnnotationData content;
  String? text;

  Annotation({
    String? id,
    required this.documentPath,
    required this.pageIndex,
    required this.drawable,
    required this.content,
    this.text,
  }) : id = id ?? DateTime.now().toIso8601String();

  @override
  String toString() {
    return 'Annotation{id: $id, documentPath: $documentPath, pageIndex: $pageIndex, drawable: $drawable, content: $content, text: $text}';
  }
}
