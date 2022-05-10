export 'package:drag_and_drop_flutter_platform_interface/drag_and_drop_flutter_platform_interface.dart';
import 'package:drag_and_drop_flutter/drag_and_drop_flutter.dart';
import 'package:flutter/widgets.dart';

/// Widget builder for [DragDropAreaBuilder].
typedef DragDropAreaWidgetBuilder = Widget Function(
  BuildContext context,
  bool isOver,
  Widget? child,
);

/// A Widget that rebuilds when data is dragged over it, and provides a callback
/// for handling dropped data.
class DragDropAreaBuilder extends StatefulWidget {
  /// Create a [DragDropAreaBuilder].
  const DragDropAreaBuilder({
    Key? key,
    required this.builder,
    this.canDrop,
    this.dragData,
    this.onDrop,
    this.child,
  }) : super(key: key);

  /// Build the child widget.
  final DragDropAreaWidgetBuilder builder;

  /// See [DragDropArea.canDrop].
  final DataTransferTypeFilter? canDrop;

  /// See [DragDropArea.dragData].
  final DragData? dragData;

  /// See [DragDropArea.onDrop].
  final DropCallback? onDrop;

  /// Passed to [builder]. Use this to avoid expensive rebuilds on parts of the
  /// tree below this widget that remain the same regardless of whether there's
  /// data dragged over this widget.
  final Widget? child;

  @override
  State<DragDropAreaBuilder> createState() => _DragDropAreaBuilderState();
}

class _DragDropAreaBuilderState extends State<DragDropAreaBuilder> {
  bool _dragOver = false;

  void setDragOver(bool value) {
    setState(() {
      _dragOver = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragDropArea(
      canDrop: widget.canDrop,
      dragData: widget.dragData,
      onDragEnter: (items) {
        if (widget.canDrop == null || widget.canDrop!(items)) {
          setDragOver(true);
        }
      },
      onDragExit: () {
        setDragOver(false);
      },
      onDrop: (items) {
        setDragOver(false);
        widget.onDrop?.call(items);
      },
      child: widget.builder(context, _dragOver, widget.child),
    );
  }
}
