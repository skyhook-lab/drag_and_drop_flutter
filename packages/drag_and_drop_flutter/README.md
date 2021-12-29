# drag_and_drop_flutter

[![pub package](https://img.shields.io/pub/v/drag_and_drop_flutter.svg?color=blue)](https://pub.dev/packages/drag_and_drop_flutter)

Support native drag and drop in Flutter.

This is a [federated plugin][1]. It currently only has an [endorsed][2] implementation for web.

## Usage

To use this plugin, add `drag_and_drop_flutter` as a [dependency in your pubspec.yaml file](https://pub.dev/drag_and_drop_flutter).

### Example

```dart
import 'package:flutter/material.dart';
import 'package:drag_and_drop_flutter/drag_and_drop_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: DragDropArea(
      onDrop: (data) {
        final text = data['text/plain']?.toString();
        if (text != null) {
          debugPrint('Dropped text: $text');
        }
      },
      child: const Center(
        child: Text('Drop stuff here'),
      ),
    ),
  ));
}
```

[1]: https://docs.flutter.dev/development/packages-and-plugins/developing-packages#federated-plugins
[2]: https://docs.flutter.dev/development/packages-and-plugins/developing-packages#endorsed-federated-plugin