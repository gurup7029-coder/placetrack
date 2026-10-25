import 'package:flutter_test/flutter_test.dart';
import 'package:placetrack/app/app.dart';

void main() {
  testWidgets('PlaceTrack app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaceTrackApp());
    // Login screen should be visible
    expect(find.text('PlaceTrack'), findsWidgets);
  });
}
