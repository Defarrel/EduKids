import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/data/drawing/drawing_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/components/win_games.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class LearnToDrawScreen extends StatefulWidget {
  final String templateImage;
  final Uint8List? initialImage;

  const LearnToDrawScreen({
    super.key,
    required this.templateImage,
    this.initialImage,
  });

  @override
  State<LearnToDrawScreen> createState() => _LearnToDrawScreenState();
}

class _LearnToDrawScreenState extends State<LearnToDrawScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _interactiveViewerKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();
  late ConfettiController _confettiController;

  ui.Image? _filledImage;
  List<ui.Image?> _fillHistory = [];
  List<DrawingPoint?> points = [];
  List<String> _actionStack = [];

  double _currentPixelRatio = 1.0;

  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  bool isEraser = false;
  bool isHandMode = false;
  bool showFillPopup = false;
  Color fillSelectedColor = Colors.blue;
  bool isProcessingFill = false;

  final List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    AudioManager().playBgm('puzzle_bgm.mp3');

    if (widget.initialImage != null) {
      _loadInitialImage();
    }
  }

  Future<void> _loadInitialImage() async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(
        widget.initialImage!,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      setState(() {
        _filledImage = frameInfo.image;
        _currentPixelRatio = 1.0;
      });
    } catch (e) {
      debugPrint("Error loading initial image: $e");
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _addPoint(Offset globalPos) {
    if (isHandMode) return;
    if (showFillPopup) setState(() => showFillPopup = false);

    RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    Offset localPos = renderBox.globalToLocal(globalPos);

    setState(() {
      points.add(
        DrawingPoint(
          offset: localPos,
          paint: Paint()
            ..color = isEraser ? Colors.transparent : selectedColor
            ..blendMode = isEraser ? BlendMode.clear : BlendMode.srcOver
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..isAntiAlias = true,
        ),
      );
    });
  }

  void _handleZoom(double scaleFactor) {
    final RenderBox? box =
        _interactiveViewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset center = Offset(box.size.width / 2, box.size.height / 2);
    final Matrix4 currentMatrix = _transformationController.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    final double newScale = (currentScale * scaleFactor).clamp(0.5, 5.0);
    final double effectiveScale = newScale / currentScale;
    final Matrix4 scaleMatrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(effectiveScale)
      ..translate(-center.dx, -center.dy);
    setState(() {
      _transformationController.value = scaleMatrix.multiplied(currentMatrix);
    });
  }

  void _zoomIn() => _handleZoom(1.2);
  void _zoomOut() => _handleZoom(0.8);

  void _openColorPickerDialog({
    required String title,
    required Color currentColor,
    required Function(Color) onColorChanged,
    required VoidCallback onSelect,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Color Picker",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: a1, curve: Curves.elasticOut).value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: const BorderSide(color: Colors.orangeAccent, width: 4),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.palette_rounded,
                    color: Colors.orange,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: onColorChanged,
                  colorPickerWidth: 250,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  hexInputBar: false,
                  labelTypes: const [],
                ),
              ),
              actions: <Widget>[
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelect();
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'SELECT',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    Color tempColor = selectedColor;
    _openColorPickerDialog(
      title: 'Warna Pen',
      currentColor: selectedColor,
      onColorChanged: (color) => tempColor = color,
      onSelect: () => setState(() {
        selectedColor = tempColor;
        isEraser = false;
        showFillPopup = false;
        isHandMode = false;
      }),
    );
  }

  void _showFillColorPicker() {
    Color tempColor = fillSelectedColor;
    _openColorPickerDialog(
      title: 'Pick a Fill Color!',
      currentColor: fillSelectedColor,
      onColorChanged: (color) => tempColor = color,
      onSelect: () => setState(() => fillSelectedColor = tempColor),
    );
  }

  Future<void> _performFloodFill(Offset tapPosition) async {
    if (isProcessingFill || isHandMode) return;

    try {
      isProcessingFill = true;

      RenderRepaintBoundary? boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      AudioManager().playSfx('bubble-pop.mp3');

      double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      if (pixelRatio > 3.0) pixelRatio = 3.0;

      ui.Image sourceImage = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await sourceImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) return;

      Uint8List pixels = byteData.buffer.asUint8List();
      int width = sourceImage.width;
      int height = sourceImage.height;

      int x = (tapPosition.dx * pixelRatio).toInt();
      int y = (tapPosition.dy * pixelRatio).toInt();

      if (x < 0) x = 0;
      if (x >= width) x = width - 1;
      if (y < 0) y = 0;
      if (y >= height) y = height - 1;

      _fillHistory.add(_filledImage);

      _floodFillAlgorithm(pixels, width, height, x, y, fillSelectedColor);

      ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
        pixels,
      );
      ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: width,
        height: height,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      ui.Codec codec = await descriptor.instantiateCodec();
      ui.FrameInfo frameInfo = await codec.getNextFrame();

      setState(() {
        _filledImage = frameInfo.image;
        _currentPixelRatio = pixelRatio;
        showFillPopup = false;
        _actionStack.add('fill');
      });
    } catch (e) {
      debugPrint("Error Fill: $e");
    } finally {
      isProcessingFill = false;
    }
  }

  void _floodFillAlgorithm(
    Uint8List pixels,
    int width,
    int height,
    int startX,
    int startY,
    Color newColor,
  ) {
    int startIndex = (startY * width + startX) * 4;

    int startR = pixels[startIndex];
    int startG = pixels[startIndex + 1];
    int startB = pixels[startIndex + 2];
    int startA = pixels[startIndex + 3];

    int newR = newColor.red;
    int newG = newColor.green;
    int newB = newColor.blue;
    int newA = newColor.alpha;

    if (startR == newR && startG == newG && startB == newB && startA == newA)
      return;

    Queue<int> queue = Queue<int>();
    queue.add(startIndex);

    const int tolerance = 120;

    while (queue.isNotEmpty) {
      int idx = queue.removeFirst();
      if (idx < 0 || idx >= pixels.length) continue;

      int r = pixels[idx];
      int g = pixels[idx + 1];
      int b = pixels[idx + 2];

      int diff = (r - startR).abs() + (g - startG).abs() + (b - startB).abs();
      bool isSimilar = diff <= tolerance;
      bool isColored = (r == newR && g == newG && b == newB);

      if (isSimilar && !isColored) {
        pixels[idx] = newR;
        pixels[idx + 1] = newG;
        pixels[idx + 2] = newB;
        pixels[idx + 3] = newA;

        int cx = (idx ~/ 4) % width;
        int cy = (idx ~/ 4) ~/ width;

        if (cx > 0) queue.add(idx - 4);
        if (cx < width - 1) queue.add(idx + 4);
        if (cy > 0) queue.add(idx - width * 4);
        if (cy < height - 1) queue.add(idx + width * 4);
      }
    }
  }

  Future<void> _onFinish() async {
    Uint8List? capturedImageBytes;
    try {
      RenderRepaintBoundary? boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        double pixelRatio = MediaQuery.of(context).devicePixelRatio;
        if (pixelRatio > 3.0) pixelRatio = 3.0;

        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        capturedImageBytes = byteData?.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint("Error saving: $e");
    }

    AudioManager().playSfx('pop.mp3');
    _confettiController.play();

    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Win",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => WinGames(
        isLastLevel: false,
        confettiController: _confettiController,
        onActionPressed: () {
          Navigator.pop(ctx);
          Navigator.pop(context, capturedImageBytes);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    key: _interactiveViewerKey,
                    color: Colors.white,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      panEnabled: isHandMode,
                      scaleEnabled: isHandMode,
                      minScale: 0.5,
                      maxScale: 5.0,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      child: Center(
                        child: RepaintBoundary(
                          key: _canvasKey,
                          child: Container(
                            width: screenWidth,
                            height: screenHeight,
                            color: Colors.white,
                            child: Stack(
                              children: [
                                if (_filledImage != null)
                                  Positioned.fill(
                                    child: RawImage(
                                      image: _filledImage,
                                      width: screenWidth,
                                      height: screenHeight,
                                      scale: _currentPixelRatio,
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.none,
                                    ),
                                  ),

                                Center(
                                  child: Opacity(
                                    opacity: _filledImage == null ? 0.3 : 0.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SvgPicture.asset(
                                        widget.templateImage,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                CustomPaint(
                                  size: Size(screenWidth, screenHeight),
                                  painter: DrawingPainter(pointsList: points),
                                ),

                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onPanStart: isHandMode
                                        ? null
                                        : (d) => _addPoint(d.globalPosition),
                                    onPanUpdate: isHandMode
                                        ? null
                                        : (d) => _addPoint(d.globalPosition),
                                    onPanEnd: isHandMode
                                        ? null
                                        : (_) => setState(() {
                                            points.add(null);
                                            _actionStack.add('draw');
                                          }),
                                    onTapUp: (details) {
                                      if (showFillPopup && !isHandMode) {
                                        RenderBox box =
                                            _canvasKey.currentContext!
                                                    .findRenderObject()
                                                as RenderBox;
                                        Offset localPos = box.globalToLocal(
                                          details.globalPosition,
                                        );
                                        _performFloodFill(localPos);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
            Positioned(right: 15, top: 80, child: _buildZoomControls()),
            if (showFillPopup)
              Positioned(bottom: 130, left: 20, child: _buildFillPopup()),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Column(
      children: [
        GestureDetector(
          onTap: _zoomIn,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.blueAccent),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _zoomOut,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.remove, color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleBtn(
            Icons.arrow_back_rounded,
            AppColors.gameGreen,
            () => Navigator.pop(context),
          ),
          Row(
            children: [
              _circleBtn(Icons.undo_rounded, Colors.blue, () {
                if (_actionStack.isNotEmpty) {
                  setState(() {
                    String lastAction = _actionStack.removeLast();
                    if (lastAction == 'draw') {
                      if (points.isNotEmpty) {
                        if (points.last == null) points.removeLast();
                        while (points.isNotEmpty && points.last != null)
                          points.removeLast();
                      }
                    } else if (lastAction == 'fill') {
                      if (_fillHistory.isNotEmpty)
                        _filledImage = _fillHistory.removeLast();
                      else
                        _filledImage = null;
                    }
                  });
                }
              }),
              const SizedBox(width: 10),
              _circleBtn(Icons.refresh_rounded, Colors.orange, () {
                setState(() {
                  points.clear();
                  _filledImage = null;
                  _actionStack.clear();
                  _fillHistory.clear();
                  _transformationController.value = Matrix4.identity();
                });
              }),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _onFinish,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.teal],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "DONE",
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  AudioManager().playSfx('pop.mp3');
                  setState(() {
                    showFillPopup = !showFillPopup;
                    isEraser = false;
                    isHandMode = false;
                  });
                },
                child: _toolButton(
                  Icons.format_color_fill_rounded,
                  showFillPopup,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () => setState(() {
                  isEraser = true;
                  showFillPopup = false;
                  isHandMode = false;
                }),
                child: _toolButton(
                  Icons.cleaning_services_rounded,
                  isEraser,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () => setState(() {
                  isHandMode = true;
                  isEraser = false;
                  showFillPopup = false;
                }),
                child: _toolButton(
                  Icons.pan_tool_rounded,
                  isHandMode,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.grey[400]),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: selectedColor,
                            thumbColor: selectedColor,
                            trackHeight: 4.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                          ),
                          child: Slider(
                            value: strokeWidth,
                            min: 2.0,
                            max: 30.0,
                            onChanged: (v) => setState(() => strokeWidth = v),
                          ),
                        ),
                      ),
                      Icon(Icons.circle, size: 20, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length + 1,
              itemBuilder: (context, index) {
                if (index == 0)
                  return GestureDetector(
                    onTap: _showColorPicker,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            Colors.red,
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.purple,
                            Colors.red,
                          ],
                        ),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: const Icon(
                        Icons.colorize,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                final c = colors[index - 1];
                bool isSelected =
                    selectedColor == c &&
                    !isEraser &&
                    !showFillPopup &&
                    !isHandMode;
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedColor = c;
                    isEraser = false;
                    showFillPopup = false;
                    isHandMode = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.black12, width: 1),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: c.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.brush, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFillPopup() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, double val, child) => Transform.scale(
        scale: val,
        alignment: Alignment.bottomLeft,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fill Color",
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => setState(() => showFillPopup = false),
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GestureDetector(
                  onTap: _showFillColorPicker,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(
                      Icons.colorize,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                ...colors.map((c) {
                  bool isSelected = fillSelectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => fillSelectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Tap inside shapes to fill!",
              style: GoogleFonts.fredoka(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      );
  Widget _toolButton(IconData icon, bool isActive, Color color) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Icon(icon, color: isActive ? color : Colors.grey),
      );
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> pointsList;
  DrawingPainter({required this.pointsList});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i]!.offset,
          pointsList[i + 1]!.offset,
          pointsList[i]!.paint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [
          pointsList[i]!.offset,
        ], pointsList[i]!.paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
