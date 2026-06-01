import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'utils/theme.dart';

// Import features
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/login_view.dart';
import 'features/dashboard/views/main_layout_view.dart';
import 'features/dashboard/views/dashboard_view.dart';
import 'features/companies/controllers/companies_controller.dart';
import 'features/companies/views/companies_view.dart';
import 'features/companies/views/company_details_view.dart';
import 'features/companies/views/add_company_view.dart';
import 'features/companies/views/edit_company_view.dart';
import 'features/investors/controllers/investors_controller.dart';
import 'features/investors/views/investors_view.dart';
import 'features/investors/views/add_investor_view.dart';
import 'features/investors/views/edit_investor_view.dart';
import 'features/members/controllers/members_controller.dart';
import 'features/members/views/members_view.dart';
import 'features/members/views/edit_member_view.dart';
import 'features/packages/controllers/packages_controller.dart';
import 'features/packages/views/packages_view.dart';
import 'features/packages/views/add_package_view.dart';
import 'features/packages/views/edit_package_view.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/settings/views/settings_view.dart';

void main() {
  runApp(const InvesTrackAdminApp());
}

class InvesTrackAdminApp extends StatelessWidget {
  const InvesTrackAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CompaniesController()),
        ChangeNotifierProvider(create: (_) => InvestorsController()),
        ChangeNotifierProvider(create: (_) => MembersController()),
        ChangeNotifierProvider(create: (_) => PackagesController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return MaterialApp.router(
        title: 'InvesTrack Admin',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayoutView(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardView(),
        ),
        GoRoute(
          path: '/companies',
          builder: (context, state) => const CompaniesView(),
        ),
        GoRoute(
          path: '/companies/add',
          builder: (context, state) => const AddCompanyView(),
        ),
        GoRoute(
          path: '/companies/view/:id',
          builder: (context, state) => CompanyDetailsView(companyId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/companies/edit/:id',
          builder: (context, state) => EditCompanyView(companyId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/investors',
          builder: (context, state) => const InvestorsView(),
        ),
        GoRoute(
          path: '/investors/add',
          builder: (context, state) => const AddInvestorView(),
        ),
        GoRoute(
          path: '/investors/edit/:id',
          builder: (context, state) => EditInvestorView(investorId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/members',
          builder: (context, state) => const MembersView(),
        ),
        GoRoute(
          path: '/members/edit/:id',
          builder: (context, state) => EditMemberView(memberId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/packages',
          builder: (context, state) => const PackagesView(),
        ),
        GoRoute(
          path: '/packages/add',
          builder: (context, state) => const AddPackageView(),
        ),
        GoRoute(
          path: '/packages/edit/:id',
          builder: (context, state) => EditPackageView(packageId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsView(),
        ),
      ],
    ),
  ],
);
