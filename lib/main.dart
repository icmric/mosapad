import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canvas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CanvasPage(),
    );
  }
}

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  Offset _canvasOffset = Offset.zero;
  Size _canvasSize = const Size(1000, 800); // Initial size

  // For zooming and panning with InteractiveViewer
  final TransformationController _transformationController = TransformationController();

  List<Offset> _boxPositions = [];
  List<TextEditingController> _textControllers = [];
  List<Widget> _textForms = [];
  List<double> _textFormWidths = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas App'),
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        transformationController: _transformationController,
        child: SizedBox(
          width: _canvasSize.width,
          height: _canvasSize.height,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () {
              updateCanvasSize(Size(2000, 800));
            },
            onTapDown: (details) {
              Offset canvasTapPosition = details.localPosition;
              setState(() {
                _textForms.add(TextField(
                  autofocus: true,
                  minLines: 1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      TextPainter textPainter = TextPainter(
                        text: TextSpan(text: text, style: const TextStyle(fontSize: 16)), // Text style for text box
                        textDirection: TextDirection.ltr,
                        maxLines: null,
                      )..layout(); // Layout without maxWidth to get the intrinsic width

                      // This is a very dodgy way of doing it, will break if an older textbox needs expanding
                      _textFormWidths[_textForms.length - 1] = (textPainter.width + 80).clamp(150, 600); // Increases width, ensures its between range (UPDATE TO USE VARIABLES)
                    });
                  },
                ));
                _boxPositions.add(canvasTapPosition);
                _textControllers.add(TextEditingController());
                _textFormWidths.add(150);
              });
            },
            // ...
            child: Stack(
              children: [
                Container(
                  // Background Container
                  width: _canvasSize.width, // Explicitly set width and height
                  height: _canvasSize.height,
                  color: Colors.grey[300],
                  child: CustomPaint(
                    // Grid painter
                    size: _canvasSize, // Provide size to the painter
                    painter: GridPainter(),
                  ),
                ),
                ..._boxPositions.asMap().entries.map((entry) {
                  // Use asMap().entries to get index
                  int index = entry.key; // Get index
                  Offset position = entry.value; // Get Offset
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: SizedBox(
                      width: _textFormWidths[index], // Use _currentWidth here
                      child: _textForms.isNotEmpty && index < _textForms.length // Check for valid index
                          ? _textForms[index]
                          : Container(), // Or any placeholder widget
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateCanvasSize(Size newSize) {
    setState(() {
      _canvasSize = newSize;
    });
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Optimization: only repaint when needed.
  }
}
