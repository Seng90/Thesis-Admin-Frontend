import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/router/app_router.dart';
import 'package:investrack_admin/utils/theme.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'features/companies/controllers/companies_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/founders/controllers/founders_controller.dart';
import 'features/funding_rounds/controllers/investments_controller.dart';
import 'features/fundraising_posts/controllers/fundraising_posts_controller.dart';
import 'features/investors/controllers/investors_controller.dart';
import 'features/members/controllers/members_controller.dart';
import 'features/packages/controllers/packages_controller.dart';
import 'features/revisions/controllers/revisions_controller.dart';
import 'features/settings/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authController = AuthController();
  final router = createAppRouter(authController);

  runApp(InvesTrackAdminApp(
    authController: authController,
    router: router,
  ));
}

class InvesTrackAdminApp extends StatelessWidget {
  final AuthController authController;
  final GoRouter router;

  const InvesTrackAdminApp({
    super.key,
    required this.authController,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => RevisionsController()),
        ChangeNotifierProvider(create: (_) => CompaniesController()),
        ChangeNotifierProvider(create: (_) => InvestorsController()),
        ChangeNotifierProvider(create: (_) => MembersController()),
        ChangeNotifierProvider(create: (_) => PackagesController()),
        ChangeNotifierProvider(create: (_) => FoundersController()),
        ChangeNotifierProvider(create: (_) => InvestmentsController()),
        ChangeNotifierProvider(create: (_) => FundraisingPostsController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return MaterialApp.router(
            title: 'InvesTrack Admin',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsController.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
