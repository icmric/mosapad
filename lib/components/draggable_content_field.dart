import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

// *** NOT FINISHED ***
// STILL TO DO
// * Fix trackpad input (lock scrolling, unlock panning?)
// * Fix touch input (same as above)

/// Represents a draggable text field on the canvas.
/// Users can drag, resize, and edit the text within these fields.
class DraggableContentField extends StatefulWidget {
  /// The initial position of the content field
  final Offset initialPosition;

  /// The minimum width of the content field
  final double? minWidth;

  /// The maximum width the content field can expand to
  final double maxWidth;

  /// The FocusNode for managing focus. Primaraly used with QuillEditor
  final FocusNode focusNode;

  final Function(QuillController)? onControllerFocus;

  final QuillController? quillController; // Add this to store the controller

  /// The content to be displayed in the content field
  ///
  /// If left null, a QuillEditor will be added *** NOT IMPLEMENTED YET ***
  ///
  /// Can accept any widgets and will be rendered in a column
  final List<Widget>? content;

  final GlobalKey globalKey = GlobalKey();

  DraggableContentField({
    required this.initialPosition,
    required this.maxWidth,
    required this.focusNode,
    this.minWidth,
    this.onControllerFocus,
    this.quillController,
    this.content,
    super.key,
  });

  @override
  DraggableContentFieldState createState() => DraggableContentFieldState();
}

class DraggableContentFieldState extends State<DraggableContentField> {
  bool isVisible = false; // Whether the text field border and toolbar are visible.
  bool isDragging = false; // Whether the text field is currently being dragged.
  double maxWidth = 800; // Current width of the text field.
  double minWidth = 200; // Minimum width of the text field.
  Offset position = Offset(0, 0); // Current position of the text field.
  late List<Widget> content;
  late GlobalKey _contentFieldKey;

  @override
  void initState() {
    super.initState();

    // Initialize values of local variables
    content = widget.content ?? [];
    maxWidth = widget.maxWidth;
    minWidth = widget.minWidth ?? 200;
    position = widget.initialPosition;
    _contentFieldKey = widget.globalKey;

    // Add focus listener
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!widget.focusNode.hasFocus && !isDragging) {
      setState(() {
        isVisible = false;
      });
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      // Makes box visible/invisible when mousing over
      child: MouseRegion(
        // Mouse starts hovering over the box
        onEnter: (_) {
          // If the box is not empty, make it visible, otherwise just show cursor
          setState(() {
            isVisible = true;
          });
        },
        // Mouse stops hovering over the box
        onExit: (_) {
          // If the box is not focused, make it invisible
          if (!widget.focusNode.hasFocus && !isDragging) {
            setState(() {
              isVisible = false;
            });
          }
        },
        child: Container(
          key: _contentFieldKey,
          child: GestureDetector(
            // On Field Drag Start
            onPanStart: (_) {
              setState(() {
                isDragging = true;
              });
            },
            // On Field Drag
            onPanUpdate: (details) {
              setState(() {
                position += details.delta;
              });
            },
            // On Field Drag End
            onPanEnd: (details) {
              setState(() {
                isDragging = false;
              });
            },
            onTap: () {
              if (widget.quillController != null) {
                setState(() {
                  widget.onControllerFocus?.call(widget.quillController!);
                });
              }
            },
            child: IntrinsicWidth(
              child: Column(
                children: [
                  // Bar ontop of the field used to drag the field around
                  Container(
                    height: 15,
                    padding: const EdgeInsets.all(0),
                    color: isVisible ? Colors.grey : Colors.transparent,
                    alignment: Alignment.center,
                    child: isVisible
                        ? const Text(
                            '...',
                            strutStyle: StrutStyle(
                              forceStrutHeight: true,
                              height: 0.1,
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )
                        : null,
                  ),
                  // The main body of the content field
                  Container(
                    // Contraints allow for dynamic resizing
                    constraints: BoxConstraints(
                      minWidth: minWidth,
                      maxWidth: maxWidth,
                    ),
                    // Content field border
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isVisible ? Colors.black : Colors.transparent,
                      ),
                    ),
                    // Content
                    child: Column(
                      children: [...content],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}