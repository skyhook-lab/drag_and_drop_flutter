import 'dart:html' as html;

import 'package:cross_file/cross_file.dart';
import 'package:drag_and_drop_flutter_platform_interface/drag_and_drop_flutter_platform_interface.dart';

class WebDirectoryEntry extends DirectoryEntry {
  const WebDirectoryEntry(this.entry);

  final html.DirectoryEntry entry;

  @override
  String get path => entry.fullPath!;

  @override
  String get name => entry.name!;

  @override
  Future<List<FilesystemEntry>> getEntries() async {
    final reader = entry.createReader();
    final entries = await reader.readEntries();
    final results = <FilesystemEntry>[];
    for (final e in entries) {
      final result = await createEntry(e);
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }
}

Future<FilesystemEntry?> createEntry(html.Entry entry) async {
  if (entry is html.FileEntry) {
    final hfile = await entry.file();
    final file = XFile(
      entry.fullPath!,
      name: hfile.name,
      lastModified: hfile.lastModifiedDate,
      length: hfile.size,
      mimeType: hfile.type,
    );
    return FileEntry(file);
  } else if (entry is html.DirectoryEntry) {
    return WebDirectoryEntry(entry);
  }

  return null;
}
