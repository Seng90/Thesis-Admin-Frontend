import 'package:flutter_test/flutter_test.dart';
import 'package:investrack_admin/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InvesTrackAdminApp());

    // Wait for the app to finish rendering the initial frame
    await tester.pumpAndSettle();

    // Verify that we are on the login screen (or whatever is the initial route)
    expect(find.text('InvesTrack Admin Login'), findsOneWidget);
  });
}
