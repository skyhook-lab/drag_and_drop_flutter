import 'package:flutter/widgets.dart';
import 'package:drag_and_drop_flutter_platform_interface/drag_and_drop_flutter_platform_interface.dart';

/// Widget that handles native drag and drop.
///
/// This widgets interfaces with the platform to get or set data for drag
/// operations.
///
/// This widgets tightens its constraints to the biggest size allowed.
class DragDropArea extends StatelessWidget {
  const DragDropArea({
    Key? key,
    this.dragData,
    this.canDrop,
    this.onDragEnter,
    this.onDragExit,
    this.onDrop,
    this.platform,
    required this.child,
  }) : super(key: key);

  /// Data that is set when users drag from this widget.
  ///
  /// Items created with [DataTransferItem.file] are ignored on web.
  final DragData? dragData;

  /// When this returns false, the area of the widget will not accept the
  /// given items.
  ///
  /// When false, [onDragEnter] and [onDragExit] will still be called. When
  /// [onDrop] would be called, [onDragExit] is called instead.
  ///
  /// On web, when `canDrop` returns false for dropped content, the default
  /// handling will happen. For example, a dropped image might open on a new
  /// tab.
  final DataTransferTypeFilter? canDrop;

  /// Called when a drag operation enters the widget's bounds.
  final DragEnterCallback? onDragEnter;

  /// Called when a drag operation leaves the widget's bounds, or data is
  /// dropped, but [canDrop] returns false for it.
  final DragExitCallback? onDragExit;

  /// Called when data is dropped on the widget and [canDrop] returns true for
  /// it.
  final DropCallback? onDrop;

  /// Set to override the native drag implementation.
  final DragAndDropFlutterPlatform? platform;

  /// The child widget wrapped by this [DragDropArea].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = platform ?? DragAndDropFlutterPlatform.instance;
    return p.buildDropArea(
      dragData: dragData,
      canDrop: canDrop,
      onDragEnter: onDragEnter,
      onDragExit: onDragExit,
      onDrop: onDrop,
      child: child,
    );
  }
}
