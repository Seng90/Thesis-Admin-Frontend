import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:investrack_admin/main.dart';
import 'package:investrack_admin/features/auth/controllers/auth_controller.dart';
import 'package:investrack_admin/router/app_router.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock initial values for SharedPreferences before building application
    SharedPreferences.setMockInitialValues({});

    final authController = AuthController();
    final router = createAppRouter(authController);

    // Build our app and trigger a frame.
    await tester.pumpWidget(InvesTrackAdminApp(
      authController: authController,
      router: router,
    ));

    // Allow initial microtasks and GoRouter redirection to resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Verify that we are on the login screen
    expect(find.text('InvesTrack Admin Login'), findsOneWidget);
  });
}
