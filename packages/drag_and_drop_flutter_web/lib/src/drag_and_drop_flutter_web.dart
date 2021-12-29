import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:drag_and_drop_flutter_platform_interface/drag_and_drop_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'directory_entry.dart';

Map<int, html.HtmlElement> _divs = {};

/// The web implementation of [DragAndDropFlutterPlatform].
///
/// This class implements the `package:drag_and_drop_flutter`
/// functionality for the web.
class DragAndDropFlutterWebPlatform extends DragAndDropFlutterPlatform {
  /// Registers this class as the default instance of [DragAndDropFlutterPlatform].
  static void registerWith(Registrar registrar) {
    DragAndDropFlutterPlatform.instance = DragAndDropFlutterWebPlatform();

    // ignore: undefined_prefixed_name, avoid_dynamic_calls
    ui.platformViewRegistry.registerViewFactory('drag_and_drop_flutter',
        (int viewId) {
      final div = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..draggable = true;
      _divs[viewId] = div;
      return div;
    });
  }

  @override
  Widget buildDropArea({
    DragData? dragData,
    DataTransferTypeFilter? canDrop,
    DragEnterCallback? onDragEnter,
    DragExitCallback? onDragExit,
    DropCallback? onDrop,
    required Widget child,
  }) {
    if (dragData == null &&
        onDragEnter == null &&
        onDragExit == null &&
        onDrop == null) {
      return child;
    }

    return DropArea(
      canDrop: canDrop,
      dragData: dragData ?? DragData(),
      onDragEnter: onDragEnter,
      onDragExit: onDragExit,
      onDrop: onDrop,
      child: child,
    );
  }
}

class DropArea extends StatefulWidget {
  const DropArea({
    Key? key,
    required this.dragData,
    this.canDrop,
    this.onDragEnter,
    this.onDragExit,
    this.onDrop,
    required this.child,
  }) : super(key: key);

  final DragData dragData;
  final DataTransferTypeFilter? canDrop;
  final DragEnterCallback? onDragEnter;
  final DragExitCallback? onDragExit;
  final DropCallback? onDrop;
  final Widget child;

  @override
  DropAreaState createState() => DropAreaState();
}

class DropAreaState extends State<DropArea> {
  html.HtmlElement? _div;
  final List<StreamSubscription> _subscriptions = [];
  bool _disposed = false;

  @override
  void didUpdateWidget(DropArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dragData.isEmpty != oldWidget.dragData.isEmpty ||
        widget.onDragEnter != oldWidget.onDragEnter ||
        widget.onDragExit != oldWidget.onDragExit ||
        widget.onDrop != oldWidget.onDrop) {
      _clearSubscriptions();
      _attachToDiv();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    _clearSubscriptions();
  }

  void _clearSubscriptions() {
    for (var s in _subscriptions) {
      s.cancel();
    }

    _subscriptions.clear();
  }

  bool _canDrop(List<DataTransferItemMetadata> items) {
    return widget.onDrop != null &&
        (widget.canDrop == null || widget.canDrop!(items));
  }

  void _attachToDiv() {
    if (_disposed || _div == null) {
      return;
    }

    final div = _div!;

    if (widget.dragData.isNotEmpty) {
      _subscriptions.add(
        div.onDragStart.listen(
          (event) {
            event.dataTransfer.dropEffect =
                _getDragTypeString(widget.dragData.type);
            for (final item in widget.dragData.items.where((d) => !d.isFile)) {
              event.dataTransfer.setData(item.type, item.data!);
            }
          },
        ),
      );
    }

    _subscriptions.add(div.onDragEnter.listen((event) {
      final metadata = _createMetadataList(event.dataTransfer);
      if (_canDrop(metadata)) {
        event.preventDefault();
      }

      final callback = widget.onDragEnter;
      if (callback != null) {
        if (metadata.isNotEmpty) {
          callback(metadata);
        }
      }
    }));

    _subscriptions.add(div.onDragOver.listen((event) {
      final metadata = _createMetadataList(event.dataTransfer);
      if (_canDrop(metadata)) {
        event.preventDefault();
      }
    }));

    _subscriptions.add(div.onDragLeave.listen((event) {
      widget.onDragExit?.call();
    }));

    _subscriptions.add(div.onDrop.listen((event) async {
      final metadata = _createMetadataList(event.dataTransfer);
      if (!_canDrop(metadata)) {
        return;
      }

      final callback = widget.onDrop;
      if (callback == null) {
        widget.onDragExit?.call();
      } else {
        event.preventDefault();

        final dataTransfer = event.dataTransfer;
        final items = dataTransfer.items;
        if (items != null) {
          final results = <DataTransferItem>[];
          for (var i = 0; i < items.length!; i++) {
            final item = items[i];

            if (item.kind == 'file') {
              // `getAsEntry` warns and fails in debug mode.
              // See https://github.com/dart-lang/sdk/issues/47786.
              final entry = await createEntry(item.getAsEntry());
              final droppedFile = DataTransferItem.file(
                type: item.type!,
                file: entry,
              );

              if (entry != null) {
                results.add(droppedFile);
              }
            } else {
              final data = dataTransfer.getData(item.type!);
              final droppedData = DataTransferItem.data(
                type: item.type!,
                data: data,
              );
              results.add(droppedData);
            }
          }

          final effect = _parseDragType(event.dataTransfer.dropEffect);
          final dd = DragData(readonly: true, items: results, type: effect);
          callback(dd);
        }
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        HtmlElementView(
          viewType: 'drag_and_drop_flutter',
          onPlatformViewCreated: (viewId) {
            _div = _divs[viewId]!;
            _attachToDiv();
          },
        ),
        widget.child,
      ],
    );
  }
}

String? _getDragTypeString(DragDropType? type) {
  if (type == null) {
    return null;
  }

  switch (type) {
    case DragDropType.copy:
      return "copy";
    case DragDropType.link:
      return "link";
    case DragDropType.move:
      return "move";
  }
}

DragDropType? _parseDragType(String? str) {
  switch (str) {
    case 'copy':
      return DragDropType.copy;
    case 'link':
      return DragDropType.link;
    case 'move':
      return DragDropType.move;
  }

  return null;
}

List<DataTransferItemMetadata> _createMetadataList(
  html.DataTransfer dataTransfer,
) {
  final items = dataTransfer.items;
  if (items == null) {
    return [];
  }

  return List.generate(items.length!, (index) {
    final item = items[index];
    return DataTransferItemMetadata(
      type: item.type!,
      isFile: item.kind == 'file',
    );
  });
}
