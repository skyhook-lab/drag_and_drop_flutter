import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Platform abstraction for building a drag and drop widget.
abstract class DragAndDropFlutterPlatform extends PlatformInterface {
  /// Constructs a [DragAndDropFlutterPlatform].
  DragAndDropFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static late DragAndDropFlutterPlatform _instance = NullDragAndDropPlatform();

  /// The default instance of [DragAndDropFlutterPlatform] to use.
  ///
  /// Defaults to an implementation that does nothing.
  static DragAndDropFlutterPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [DragAndDropFlutterPlatform] when they register themselves.
  static set instance(DragAndDropFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Create a widget that can get or set drag and drop data in its area.
  Widget buildDropArea({
    DragData? dragData,
    bool Function(List<DataTransferItemMetadata>)? canDrop,
    DragEnterCallback? onDragEnter,
    DragExitCallback? onDragExit,
    DropCallback? onDrop,
    required Widget child,
  });
}

/// An implementation of [DragAndDropFlutterPlatform] that does nothing.
class NullDragAndDropPlatform extends DragAndDropFlutterPlatform {
  /// Returns [child] without handling drag and drop operations.
  @override
  Widget buildDropArea({
    DragData? dragData,
    bool Function(List<DataTransferItemMetadata>)? canDrop,
    DragEnterCallback? onDragEnter,
    DragExitCallback? onDragExit,
    DropCallback? onDrop,
    required Widget child,
  }) {
    return child;
  }
}

/// Function signature for `canDrop` in
/// [DragAndDropFlutterPlatform.buildDropArea].
typedef DataTransferTypeFilter = bool Function(List<DataTransferItemMetadata>);

/// Function signature for `onDragEnter` in
/// [DragAndDropFlutterPlatform.buildDropArea].
typedef DragEnterCallback = void Function(List<DataTransferItemMetadata> items);

/// Function signature for `onDragExit` in
/// [DragAndDropFlutterPlatform.buildDropArea].
typedef DragExitCallback = VoidCallback;

/// Function signature for `onDrop` in
/// [DragAndDropFlutterPlatform.buildDropArea].
typedef DropCallback = void Function(DragData data);

/// The type of a drag and drop operation.
enum DragDropType {
  /// The content is meant to be copied to the target.
  copy,

  /// A link should be created from the target to the source content.
  link,

  /// The content should be moved from the source to the target.
  ///
  /// The source should handle the deletion of its copy.
  move,
}

/// Data for a drag and drop operation.
///
/// Each item in [items] has a MIME-type and some data associated with it.
/// The data can either be a [String] value or a reference to a file or
/// directory. The different types of data in [items] are ordered from most
/// to least preferred, so insert whichever type you think is most important
/// first. It's recommended you always include a string with type `text/plain`
/// as a fallback value (typically as the last item).
///
/// Various types of data can be included in order from most preferred to least
/// preferred type.
///
/// # Example
///
/// For a URI, the recommended MIME-types are `text/uri-list` and `text/plain`.
///
/// ```dart
/// DragData.fromMap(
///   items: {
///     'text/uri-list': 'https://jjagg.dev',
///     'text/plain': 'https://jjagg.dev',
///   }
/// );
/// ```
class DragData {
  /// Create [DragData] with a list of [DataTransferItem].
  DragData({
    this.readonly = false,
    this.type,
    List<DataTransferItem>? items,
  })  : _items = items ?? (readonly ? const [] : []);

  /// Create [DragData] with a key-value map of [String] data.
  ///
  /// To include file or directory references, use [new DragData].
  DragData.fromMap({
    this.readonly = false,
    this.type,
    Map<String, String>? items,
  })  : _items = items?.entries
                .map((e) => DataTransferItem.data(type: e.key, data: e.value))
                .toList() ??
            (readonly ? const [] : []);

  /// Set to true to disallow editing [items].
  final bool readonly;

  /// The type of operation. This may affect cursor display.
  final DragDropType? type;
  final List<DataTransferItem> _items;

  /// The data for this drag and drop operation.
  ///
  /// If [readonly] is false, the returned list can be directly edited.
  List<DataTransferItem> get items =>
      readonly ? List.unmodifiable(_items) : _items;

  /// True if [items] is empty.
  bool get isEmpty => _items.isEmpty;

  /// True if [items] is not empty.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Check if there is data in [items] with the given MIME-type.
  bool hasData(String type) => _items.any((item) => item.type == type);

  /// Get the data in [items] with the given MIME-type.
  DataTransferItem? operator [](String type) {
    return items.firstWhereOrNull((item) => item.type == type);
  }
}

/// Metadata of a a [DataTransferItem].
///
/// This is shared when data is dragged over a widget supporting drag and drop.
/// The contents of the [DataTransferItem] are not shared until a drop action
/// occurs.
///
/// The types of data can be checked to see whether the data can be handled by
/// the drop zone.
class DataTransferItemMetadata {
  const DataTransferItemMetadata({
    required this.type,
    required this.isFile,
  });

  /// The MIME-type of the data.
  final String type;

  /// Indicates whether the item is a file or directory reference, or plain
  /// string data.
  final bool isFile;
}

/// An item in a drag operation.
///
/// The item can be a plain string, or a file or directory reference.
/// You can distinguish these cases using [isFile].
class DataTransferItem {
  /// Create an item with a file or directory reference.
  const DataTransferItem.file({
    required this.type,
    required this.file,
  }) : data = null;

  /// Create an item with string data.
  const DataTransferItem.data({
    required this.type,
    required this.data,
  }) : file = null;

  /// MIME-type of the item.
  final String type;

  /// If true, [file] is not null. Else [data] is not null.
  bool get isFile => file != null;

  /// File data of this item. Can be either a directory or a file.
  final FilesystemEntry? file;

  /// String data of this item.
  final String? data;
}

/// Abstraction for a directory or file in a drag operation.
///
/// Type check against [FileEntry] or [DirectoryEntry] to specialize.
abstract class FilesystemEntry {
  /// Full path of the directory.
  ///
  /// For web this is always `/` followed by [name] because there's no
  /// filesystem access.
  String get path;

  /// The name of the file or directory.
  String get name;
}

/// A file set on a drag operation.
class FileEntry implements FilesystemEntry {
  const FileEntry(this.file);

  /// Provides cross-platform access to the file and its contents.
  final XFile file;

  @override
  String get name => file.name;

  @override
  String get path => file.path;
}

/// A directory set on a drag operation.
abstract class DirectoryEntry implements FilesystemEntry {
  const DirectoryEntry();

  /// Get the contents of the directory.
  Future<List<FilesystemEntry>> getEntries();
}
