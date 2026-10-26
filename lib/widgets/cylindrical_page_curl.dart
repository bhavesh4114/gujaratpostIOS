import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Flutter equivalent of Android's BookPageCurlView.
/// Real 3D GPU mesh conical page curl with specular highlights,
/// paper shading, and mirrored backside bleed-through text.
class CylindricalPageCurl extends StatefulWidget {
  final int itemCount;
  final int initialIndex;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onPageChanged;

  const CylindricalPageCurl({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialIndex = 0,
    this.onPageChanged,
  });

  @override
  State<CylindricalPageCurl> createState() => CylindricalPageCurlState();
}

class CylindricalPageCurlState extends State<CylindricalPageCurl>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late final AnimationController _settleController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  ui.Image? _frontSnapshot;
  double _progress = 0;
  double _settleStart = 0;
  double _settleEnd = 0;
  double _dragWidth = 1;
  double _dragStartX = 0;
  bool? _isForward;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.itemCount == 0
        ? 0
        : widget.initialIndex.clamp(0, widget.itemCount - 1);
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        if (!mounted) return;
        final t = Curves.easeInOutCubic.transform(_settleController.value);
        setState(() {
          _progress = _settleStart + (_settleEnd - _settleStart) * t;
        });
      });
    _scheduleCapture();
  }

  @override
  void didUpdateWidget(covariant CylindricalPageCurl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount == 0) {
      _currentIndex = 0;
      _progress = 0;
    } else if (_currentIndex >= widget.itemCount) {
      _currentIndex = widget.itemCount - 1;
    }
    _scheduleCapture();
  }

  @override
  void dispose() {
    _settleController.dispose();
    _frontSnapshot?.dispose();
    _frontSnapshot = null;
    super.dispose();
  }

  void _scheduleCapture() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _captureCurrentSnapshot();
    });
  }

  Future<void> _captureCurrentSnapshot() async {
    if (!mounted) return;
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null && boundary.hasSize) {
        final img = await boundary.toImage(pixelRatio: 1.0);
        if (mounted) {
          final old = _frontSnapshot;
          setState(() {
            _frontSnapshot = img;
          });
          old?.dispose();
        } else {
          img.dispose();
        }
      }
    } catch (_) {}
  }

  void animateToPage(int targetIndex) {
    if (_settleController.isAnimating ||
        targetIndex == _currentIndex ||
        targetIndex < 0 ||
        targetIndex >= widget.itemCount ||
        _size.width <= 0) {
      return;
    }
    _isForward = targetIndex > _currentIndex;
    _dragStartX = _isForward! ? _size.width : 0;
    _settleTo(1, targetIndex: targetIndex);
  }

  void _onDragDown(DragDownDetails details, Size size) {
    if (_settleController.isAnimating || widget.itemCount < 2) return;
    _dragWidth = size.width;
    _dragStartX = details.localPosition.dx;
    _isForward = null;
    _progress = 0;
    _captureCurrentSnapshot();
  }

  void _onDragUpdate(DragUpdateDetails details, Size size) {
    if (_settleController.isAnimating || widget.itemCount < 2) return;
    final dx = details.localPosition.dx - _dragStartX;
    if (_isForward == null && dx.abs() > 4) _isForward = dx < 0;
    final forward = _isForward;
    if (forward == null ||
        (forward && _currentIndex >= widget.itemCount - 1) ||
        (!forward && _currentIndex <= 0)) {
      return;
    }
    setState(() {
      _progress = ((forward ? -dx : dx) / _dragWidth).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final forward = _isForward;
    if (forward == null || _progress <= 0) {
      _resetDrag();
      return;
    }
    final velocity = details.primaryVelocity ?? 0;
    final flung = forward ? velocity < -450 : velocity > 450;
    final shouldTurn = _progress >= .26 || flung;
    _settleTo(
      shouldTurn ? 1 : 0,
      targetIndex: shouldTurn
          ? _currentIndex + (forward ? 1 : -1)
          : null,
    );
  }

  void _settleTo(double target, {int? targetIndex}) {
    _settleStart = _progress;
    _settleEnd = target;
    _settleController.duration = Duration(
      milliseconds: (140 + 160 * (target - _progress).abs())
          .round()
          .clamp(140, 300),
    );
    _settleController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        if (targetIndex != null) _currentIndex = targetIndex;
        _progress = 0;
        _isForward = null;
      });
      _scheduleCapture();
      if (targetIndex != null) widget.onPageChanged?.call(_currentIndex);
    });
  }

  void _resetDrag() {
    setState(() {
      _progress = 0;
      _isForward = null;
    });
  }

  Widget _buildTurn(Size size, bool forward) {
    final nextIndex = _currentIndex + (forward ? 1 : -1);
    final destinationWidget = widget.itemBuilder(context, nextIndex);
    final snapshot = _frontSnapshot;

    if (snapshot != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Destination page underneath
          destinationWidget,

          // Authentic 3D Conical Mesh Page Curl (matching Android BookPageCurlView)
          CustomPaint(
            size: size,
            painter: _PageCurlMeshPainter(
              frontImage: snapshot,
              progress: _progress,
              isReverse: !forward,
            ),
          ),
        ],
      );
    }

    // Fallback if snapshot is not yet ready
    return Stack(
      fit: StackFit.expand,
      children: [
        destinationWidget,
        widget.itemBuilder(context, _currentIndex),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      _size = size;
      final forward = _isForward;
      final turning = _progress > .001 &&
          forward != null &&
          (forward
              ? _currentIndex < widget.itemCount - 1
              : _currentIndex > 0);
      final child = turning
          ? _buildTurn(size, forward)
          : RepaintBoundary(
              key: _repaintBoundaryKey,
              child: widget.itemBuilder(context, _currentIndex),
            );
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragDown: (details) => _onDragDown(details, size),
        onHorizontalDragUpdate: (details) => _onDragUpdate(details, size),
        onHorizontalDragEnd: _onDragEnd,
        child: child,
      );
    });
  }
}

/// 3D Mesh Painter rendering the continuous top-right corner conical curl -> vertical cylindrical roll,
/// matching BookPageCurlView.kt line-for-line in Skia drawVertices.
class _PageCurlMeshPainter extends CustomPainter {
  final ui.Image frontImage;
  final double progress;
  final bool isReverse;

  static const int meshWidth = 36;
  static const int meshHeight = 36;

  _PageCurlMeshPainter({
    required this.frontImage,
    required this.progress,
    required this.isReverse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = progress.clamp(0.0, 1.0);

    if (p <= 0.001) {
      canvas.drawImage(frontImage, Offset.zero, Paint());
      return;
    }

    // Phase 1 (0 -> 0.40): fold angle sweeps from 45 deg diagonal to 0 deg vertical
    final phase1Factor = (p / 0.40).clamp(0.0, 1.0);
    final angle = (math.pi / 4.0) * (1.0 - phase1Factor);
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    // Fold line origin moves left across the page as progress increases
    final originX = w * (1.0 - p * 1.25);
    const originY = 0.0;

    // Thicker cylinder radius for a prominent, thick paper roll fold
    final r = (w * 0.28) * (1.0 - 0.15 * p);

    // Simple perspective camera
    final cameraZ = w * 2.5;
    final centerX = w * 0.5;
    final centerY = h * 0.5;

    // Directional light (upper-left-front)
    const lightX = -0.3;
    const lightY = -0.5;
    const lightZ = 0.816;

    final vertexCount = (meshWidth + 1) * (meshHeight + 1);
    final positions = Float32List(vertexCount * 2);
    final frontTexCoords = Float32List(vertexCount * 2);
    final backTexCoords = Float32List(vertexCount * 2);
    final frontColors = Int32List(vertexCount);
    final backColors = Int32List(vertexCount);

    final imgW = frontImage.width.toDouble();
    final imgH = frontImage.height.toDouble();

    var idx = 0;
    for (int j = 0; j <= meshHeight; j++) {
      final y0 = (j / meshHeight) * h;
      final vTex = (j / meshHeight) * imgH;

      for (int i = 0; i <= meshWidth; i++) {
        final x0 = (i / meshWidth) * w;
        final uTex = (i / meshWidth) * imgW;
        final uTexMirror = (1.0 - i / meshWidth) * imgW;

        frontTexCoords[idx * 2] = uTex;
        frontTexCoords[idx * 2 + 1] = vTex;

        backTexCoords[idx * 2] = uTexMirror;
        backTexCoords[idx * 2 + 1] = vTex;

        final geometryX = isReverse ? w - x0 : x0;
        final dx = geometryX - originX;
        final dy = y0 - originY;
        final d = dx * cosA + dy * sinA;

        double x3d, y3d, z3d;
        double nx, ny, nz;
        bool isBackside = false;

        if (d <= 0.0) {
          x3d = x0;
          y3d = y0;
          z3d = 0.0;
          nx = 0.0;
          ny = 0.0;
          nz = 1.0;
        } else {
          final beta = d / r;
          final sinB = math.sin(beta);
          final cosB = math.cos(beta);

          final horizontalDirection = isReverse ? 1.0 : -1.0;
          x3d = x0 + horizontalDirection * (d * cosA - r * sinB * cosA);
          y3d = y0 - d * sinA + r * sinB * sinA;
          z3d = r * (1.0 - cosB);

          nx = (isReverse ? -1.0 : 1.0) * cosA * sinB;
          ny = sinA * sinB;
          nz = cosB;

          if (cosB < 0.0) isBackside = true;
        }

        final scale = cameraZ / (cameraZ + z3d);
        final projX = centerX + (x3d - centerX) * scale;
        final projY = centerY + (y3d - centerY) * scale;

        positions[idx * 2] = projX;
        positions[idx * 2 + 1] = projY;

        // Lighting calculation
        final dot = (nx * lightX + ny * lightY + nz * lightZ).clamp(0.0, 1.0);
        final spec = math.pow(dot, 10.0) * 0.45;

        if (d <= 0.0) {
          // Flat page area: deeper shadow cast by the thick fold
          final shadowDist = dx.abs();
          final shadowAlpha = shadowDist < r * 1.6
              ? ((1.0 - shadowDist / (r * 1.6)) * 0.65 * p).clamp(0.0, 0.75)
              : 0.0;
          final shade = (255 * (1.0 - shadowAlpha)).round().clamp(0, 255);
          frontColors[idx] = ((0xFF << 24) | (shade << 16) | (shade << 8) | shade).toSigned(32);
          backColors[idx] = 0;
        } else if (isBackside) {
          // Backside: thick lit paper (opaque, solid feel) + mirrored reverse texture
          frontColors[idx] = 0;
          final lighting = (0.70 + 0.30 * dot).clamp(0.55, 1.0);
          const paperAlpha = 252; // Thick, solid paper stock
          final highlightAdd = spec > 0.15 ? (((spec - 0.15) * 70).round().clamp(0, 35)) : 0;
          final litR = ((250 * lighting).round() + highlightAdd).clamp(0, 255);
          final litG = ((248 * lighting).round() + highlightAdd).clamp(0, 255);
          final litB = ((244 * lighting).round() + highlightAdd).clamp(0, 255);
          backColors[idx] = ((paperAlpha << 24) | (litR << 16) | (litG << 8) | litB).toSigned(32);
        } else {
          // Frontside curling portion: richer highlight and 3D curve shading
          backColors[idx] = 0;
          final shadow = spec > 0.12 ? 0 : (((0.5 - dot) * 220 * p).round().clamp(0, 160));
          final shade = (255 - shadow).clamp(0, 255);
          frontColors[idx] = ((0xFF << 24) | (shade << 16) | (shade << 8) | shade).toSigned(32);
        }

        idx++;
      }
    }

    // Build triangle index list
    final indexCount = meshWidth * meshHeight * 6;
    final indices = Uint16List(indexCount);
    var triIdx = 0;
    for (int j = 0; j < meshHeight; j++) {
      for (int i = 0; i < meshWidth; i++) {
        final p0 = j * (meshWidth + 1) + i;
        final p1 = p0 + 1;
        final p2 = (j + 1) * (meshWidth + 1) + i;
        final p3 = p2 + 1;

        indices[triIdx++] = p0;
        indices[triIdx++] = p2;
        indices[triIdx++] = p1;

        indices[triIdx++] = p1;
        indices[triIdx++] = p2;
        indices[triIdx++] = p3;
      }
    }

    final sx = w / imgW;
    final sy = h / imgH;
    final matrix = Float64List.fromList(
      Matrix4.diagonal3Values(sx, sy, 1.0).storage,
    );
    final shader = ImageShader(
      frontImage,
      TileMode.clamp,
      TileMode.clamp,
      matrix,
    );
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.medium
      ..shader = shader;

    // Pass 1: Frontside deformed mesh
    final frontVertices = ui.Vertices.raw(
      VertexMode.triangles,
      positions,
      textureCoordinates: frontTexCoords,
      colors: frontColors,
      indices: indices,
    );
    canvas.drawVertices(frontVertices, BlendMode.modulate, paint);

    // Pass 2: Backside mirrored mesh (lit paper tint + reverse front content)
    final backVertices = ui.Vertices.raw(
      VertexMode.triangles,
      positions,
      textureCoordinates: backTexCoords,
      colors: backColors,
      indices: indices,
    );
    canvas.drawVertices(backVertices, BlendMode.modulate, paint);
  }

  @override
  bool shouldRepaint(covariant _PageCurlMeshPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isReverse != isReverse ||
        oldDelegate.frontImage != frontImage;
  }
}
