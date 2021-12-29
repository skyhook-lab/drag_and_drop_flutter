import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drag_and_drop_flutter_platform_interface/drag_and_drop_flutter_platform_interface.dart';
import 'package:drag_and_drop_flutter_web/drag_and_drop_flutter_web.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DragAndDropFlutterWebPlatform is set', (tester) async {
    expect(DragAndDropFlutterPlatform.instance,
        isA<DragAndDropFlutterWebPlatform>());
  });
}
