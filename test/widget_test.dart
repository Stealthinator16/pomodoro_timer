import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pomodoro_timer/main.dart';
import 'package:pomodoro_timer/storage_service.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(storage: StorageService(prefs)));

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Ready?'), findsOneWidget);
  });
}
