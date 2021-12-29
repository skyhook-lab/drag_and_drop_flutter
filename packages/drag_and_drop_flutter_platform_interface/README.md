# drag_and_drop_flutter_platform_interface

A common platform interface for the [`drag_and_drop_flutter`][1] plugin.

This interface allows platform-specific implementations of the `drag_and_drop_flutter`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `drag_and_drop_flutter`, extend
[`DragAndDropFlutterPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`DragAndDropFlutterPlatform` by calling
`DragAndDropFlutterPlatform.instance = DragAndDropFlutterMyPlatform()`.

[1]: https://pub.dev/packages/drag_and_drop_flutter
[2]: lib/drag_and_drop_flutter_platform_interface.dart
