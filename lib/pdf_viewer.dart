import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'annotation_manager.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dialog.dart';

class PdfViewerPage extends StatefulWidget {
  final Directory directory;
  final int? initialPage;

  const PdfViewerPage({required this.directory, this.initialPage});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final AnnotationManager _annotationManager = AnnotationManager();
  List<File> _imageFiles = [];
  final Map<int, List<Annotation>> _pageAnnotations = {};
  final List<PainterController> _controllers = [];
  final List<double> _rotationAngles = [];
  bool loading = true;
  FocusNode textFocusNode = FocusNode();
  Annotation? currentAnnotation;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _initializePainterControllers();
  }

  void _loadImages() {
    _imageFiles = widget.directory.listSync().whereType<File>().toList();
  }

  void _loadAnnotations() {
    for (var annotation in _annotationManager.getAllAnnotations()) {
      if (annotation.documentPath == widget.directory.path) {
        if (!_pageAnnotations.containsKey(annotation.pageIndex)) {
          _pageAnnotations[annotation.pageIndex] = [];
        }
        List<Drawable> list = [];
        print(annotation);
        if (annotation.isText) {
          list.add(TextDrawable(
            text: annotation.content.length == 1 ? annotation.content.first : '',
            position: Offset(annotation.offsetX, annotation.offsetY),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 18,
            ),
          ));
        } else {
          list.add(OvalDrawable(
            size: annotation.size,
            position: Offset(annotation.offsetX, annotation.offsetY),
            paint: Paint()
              ..strokeWidth = 5
              ..color = Colors.red
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round,
          ));
        }
        print(list);
        _controllers[annotation.pageIndex].addDrawables(list);
        _pageAnnotations[annotation.pageIndex]!.add(annotation);
      }
    }
  }

  void _initializePainterControllers() async {
    for (var imageFile in _imageFiles) {
      var controller = await _createPainterController(imageFile);
      controller.scalingEnabled = true;
      _controllers.add(controller);
      _rotationAngles.add(0.0);
    }
    _loadAnnotations();
    setState(() {
      loading = false;
      _addCurrentControllerListener();
    });
  }

  void _addCurrentControllerListener() {
    _controllers[_currentPageIndex].addListener(_selectedDrawableListener);
  }

  void _selectedDrawableListener() {
    final currentController = _controllers[_currentPageIndex];

    if (currentController.selectedObjectDrawable != null) {
      final selectedDrawable = currentController.selectedObjectDrawable;
      if (selectedDrawable != null) {
        if (currentAnnotation == null) {
          final annotation = _annotationManager.findAnnotation(
            '${widget.directory.path}/page$_currentPageIndex',
            selectedDrawable.position.dx,
            selectedDrawable.position.dy,
            selectedDrawable.getSize(),
            selectedDrawable.runtimeType == TextDrawable,
          );
          if (annotation != null) {
            setState(() {
              currentAnnotation = annotation;
            });
          }
        }

        saveAnnotation(_currentPageIndex, selectedDrawable);
      }
    } else {
      setState(() {
        currentAnnotation = null;
      });
    }
  }

  Future<PainterController> _createPainterController(File imageFile) async {
    final image = await FileImage(imageFile).image;

    final controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: textFocusNode,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 18,
          ),
        ),
        freeStyle: const FreeStyleSettings(
          color: Colors.red,
          strokeWidth: 5,
        ),
        shape: ShapeSettings(
          paint: Paint()
            ..strokeWidth = 5
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        ),
      ),
      background: image.backgroundDrawable,
    );

    return controller;
  }

  void _addAnnotation(int pageIndex, Offset offset, Size size) {
    bool isAnnotationText =
        _controllers[_currentPageIndex].selectedObjectDrawable.runtimeType ==
            TextDrawable;
    final annotation = Annotation(
        documentPath: widget.directory.path,
        pageIndex: pageIndex,
        offsetX: offset.dx,
        offsetY: offset.dy,
        size: size,
        content: isAnnotationText
            ? [
                (_controllers[_currentPageIndex].selectedObjectDrawable
                        as TextDrawable)
                    .text
              ]
            : [],
        isText: isAnnotationText);
    setState(() {
      if (!_pageAnnotations.containsKey(pageIndex)) {
        _pageAnnotations[pageIndex] = [];
      }
      _pageAnnotations[pageIndex]!.add(annotation);
      currentAnnotation = annotation;
    });
    _annotationManager.addAnnotation(
      '${widget.directory.path}/page$pageIndex',
      annotation,
    );
  }

  Future<void> _showEditAnnotationDialog(
      int pageIndex, String annotationId) async {
    final annotation = _annotationManager.findAnnotationById(
        '${widget.directory.path}/page$pageIndex', annotationId);

    if (annotation != null) {
      final newContent = await showDialog<String>(
        context: context,
        builder: (context) => ContractorDialog(values: annotation.content),
      );

      if (newContent != null && newContent.isNotEmpty) {
        setState(() {
          annotation.content = [newContent];
        });
        _annotationManager.updateAnnotation(
          '${widget.directory.path}/page$pageIndex',
          annotation,
        );
      }
    }
  }

  void _setFreeStyleStrokeWidth(double value) {
    setState(() {
      _controllers[_currentPageIndex].freeStyleStrokeWidth = value;
    });
  }

  void _setFreeStyleColor(double hue) {
    setState(() {
      _controllers[_currentPageIndex].freeStyleColor =
          HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    });
  }

  void _setTextFontSize(double size) {
    setState(() {
      _controllers[_currentPageIndex].textSettings =
          _controllers[_currentPageIndex].textSettings.copyWith(
                textStyle: _controllers[_currentPageIndex]
                    .textSettings
                    .textStyle
                    .copyWith(fontSize: size),
              );
    });
  }

  void _setShapeFactoryPaint(Paint paint) {
    setState(() {
      _controllers[_currentPageIndex].shapePaint = paint;
    });
  }

  void addText() {
    if (_controllers[_currentPageIndex].freeStyleMode != FreeStyleMode.none) {
      _controllers[_currentPageIndex].freeStyleMode = FreeStyleMode.none;
    }
    _controllers[_currentPageIndex].addText();
  }

  void setTextFontSize(double size) {
    setState(() {
      _controllers[_currentPageIndex].textSettings =
          _controllers[_currentPageIndex].textSettings.copyWith(
              textStyle: _controllers[_currentPageIndex]
                  .textSettings
                  .textStyle
                  .copyWith(fontSize: size));
    });
  }

  void _setTextColor(double hue) {
    setState(() {
      _controllers[_currentPageIndex].textStyle =
          _controllers[_currentPageIndex]
              .textStyle
              .copyWith(color: HSVColor.fromAHSV(1, hue, 1, 1).toColor());
    });
  }

  void removeSelectedDrawable(int index) {
    final selectedDrawable =
        _controllers[_currentPageIndex].selectedObjectDrawable;

    final key = '${widget.directory.path}/page$index';
    final annotation =
        _annotationManager.findAnnotationById(key, currentAnnotation!.id);
    if (annotation != null) {
      print('Removing: $annotation');
      _annotationManager.removeAnnotation(key, annotation);
    }

    if (selectedDrawable != null) {
      _controllers[_currentPageIndex].deselectObjectDrawable();
      _controllers[_currentPageIndex].removeDrawable(selectedDrawable);
    }
  }

  void _selectShape(ShapeFactory? factory) {
    setState(() {
      _controllers[_currentPageIndex].scalingEnabled = false;
      // _controllers[_currentPageIndex].
      _controllers[_currentPageIndex].shapeFactory = factory;
    });
  }

  void saveAnnotation(int index, ObjectDrawable d) {
    final key = '${widget.directory.path}/page$index';

    ObjectDrawable? selectedDrawable = _controllers[_currentPageIndex].selectedObjectDrawable;

    if (currentAnnotation != null) {
      Annotation annotation =
          _annotationManager.findAnnotationById(key, currentAnnotation!.id)!;
      String? updatedContent = selectedDrawable.runtimeType == TextDrawable ? (selectedDrawable as TextDrawable).text : null;
      _annotationManager.updateAnnotation(
          key,
          Annotation(
            id: annotation.id,
            documentPath: annotation.documentPath,
            pageIndex: annotation.pageIndex,
            content: updatedContent != null ? [updatedContent] : annotation.content,
            size: d.getSize(),
            offsetX: d.position.dx,
            offsetY: d.position.dy,
            isText: updatedContent != null,
          ));
    } else {
      print('adding new annotation!');
      _addAnnotation(index, d.position, d.getSize());
    }
  }

  void _goToPage(int index) {
    if (index >= 0 && index < _controllers.length) {
      setState(() {
        _currentPageIndex = index;
      });
      _addCurrentControllerListener();
    }
  }

  void _rotateImage(int index) {
    setState(() {
      _rotationAngles[index] += pi / 2;
      if (_rotationAngles[index] >= 2 * pi) {
        _rotationAngles[index] = 0;
      }
    });
  }

  bool _isDistorted(double angle) {
    return angle == pi / 2 || angle == 3 * pi / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.directory.path),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentPageIndex > 0) {
                _goToPage(_currentPageIndex - 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              if (_currentPageIndex < _controllers.length - 1) {
                _goToPage(_currentPageIndex + 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: () {
              _rotateImage(_currentPageIndex);
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: MediaQuery.of(context).size.width,
                    child: Transform.rotate(
                        angle: _rotationAngles[_currentPageIndex],
                        child: Transform.scale(
                          scale:
                              _isDistorted(_rotationAngles[_currentPageIndex])
                                  ? MediaQuery.of(context).size.width /
                                      (MediaQuery.of(context).size.height * 0.8)
                                  : 1,
                          child: FlutterPainter(
                            controller: _controllers[_currentPageIndex],
                          ),
                        )),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: ValueListenableBuilder(
                      valueListenable: _controllers[_currentPageIndex],
                      builder: (context, _, __) => Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: const Offset(0, 3),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: _controllers[
                                                        _currentPageIndex]
                                                    .selectedObjectDrawable !=
                                                null
                                            ? [
                                                if (_controllers[
                                                            _currentPageIndex]
                                                        .selectedObjectDrawable!
                                                        .runtimeType !=
                                                    TextDrawable)
                                                  _buildEditAnnotationIcon(
                                                      _currentPageIndex),
                                                _buildRemoveDrawableIcon(
                                                    _currentPageIndex),
                                              ]
                                            : [
                                                _buildUndoRedoIcons(),
                                                _buildShapeIcons(),
                                              ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (textFocusNode.hasFocus) ...[
                                Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                  flex: 1,
                                                  child: Text('Font Size')),
                                              Expanded(
                                                flex: 3,
                                                child: Slider.adaptive(
                                                    min: 8,
                                                    max: 96,
                                                    value: _controllers[
                                                                _currentPageIndex]
                                                            .textStyle
                                                            .fontSize ??
                                                        14,
                                                    onChanged: setTextFontSize),
                                              ),
                                            ],
                                          ),
                                        ))),
                              ],
                            ],
                          )),
                )
              ],
            ),
    );
  }

  Row _buildShapeIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.text_fields),
          tooltip: 'Add Text',
          onPressed: () {
            addText();
          },
        ),
        IconButton(
          icon: const Icon(Icons.circle),
          tooltip: 'Draw ellipse',
          onPressed: () {
            _selectShape(
              OvalFactory(),
            );
          },
        ),
        IconButton(
          icon: const Icon(PhosphorIconsBold.lineSegment),
          tooltip: 'Draw line',
          onPressed: () {
            _selectShape(
              LineFactory(),
            );
          },
        ),
      ],
    );
  }

  Row _buildColorPickerIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final hue in [0, 120, 240])
          GestureDetector(
            onTap: () => _setFreeStyleColor(hue.toDouble()),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: HSVColor.fromAHSV(1, hue.toDouble(), 1, 1).toColor(),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Row _buildFontSizePickerIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.format_size),
          tooltip: 'Font size',
          onPressed: () {
            _setTextFontSize(
              (_controllers[_currentPageIndex]
                          .textSettings
                          .textStyle
                          .fontSize ??
                      14) +
                  2,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.format_color_text),
          tooltip: 'Text color',
          onPressed: () {
            _setTextColor(
              (_controllers[_currentPageIndex].textSettings.textStyle.color ??
                      Colors.black)
                  .value
                  .toDouble(),
            );
          },
        ),
      ],
    );
  }

  Row _buildUndoRedoIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.undo),
          tooltip: 'Undo',
          onPressed: () {
            _controllers[_currentPageIndex].undo();
          },
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          tooltip: 'Redo',
          onPressed: () {
            _controllers[_currentPageIndex].redo();
          },
        ),
      ],
    );
  }

  IconButton _buildRemoveDrawableIcon(int index) {
    return IconButton(
      icon: const Icon(Icons.delete),
      tooltip: 'Remove selected drawable',
      onPressed: () {
        removeSelectedDrawable(index);
      },
    );
  }

  IconButton _buildEditAnnotationIcon(int index) {
    return IconButton(
      icon: const Icon(Icons.add_comment),
      tooltip: 'Add Data',
      onPressed: () async {
        if (currentAnnotation != null) {
          await _showEditAnnotationDialog(index, currentAnnotation!.id);
        }
      },
    );
  }
}
