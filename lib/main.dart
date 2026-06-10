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
import 'features/investors/views/investor_details_view.dart';
import 'features/members/controllers/members_controller.dart';
import 'features/members/views/members_view.dart';
import 'features/members/views/edit_member_view.dart';
import 'features/members/views/member_details_view.dart';
import 'features/revisions/views/moderations_view.dart';
import 'features/packages/controllers/packages_controller.dart';
import 'features/packages/views/packages_view.dart';
import 'features/packages/views/add_package_view.dart';
import 'features/packages/views/edit_package_view.dart';
import 'features/packages/views/package_details_view.dart';
import 'features/founders/controllers/founders_controller.dart';
import 'features/founders/views/founders_view.dart';
import 'features/founders/views/add_founder_view.dart';
import 'features/founders/views/edit_founder_view.dart';
import 'features/founders/views/founder_details_view.dart';
import 'features/funding_rounds/controllers/investments_controller.dart';
import 'features/funding_rounds/views/investments_view.dart';
import 'features/funding_rounds/views/add_investment_view.dart';
import 'features/funding_rounds/views/edit_investment_view.dart';
import 'features/funding_rounds/views/investment_details_view.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/fundraising_posts/controllers/fundraising_posts_controller.dart';
import 'features/fundraising_posts/views/fundraising_posts_view.dart';
import 'features/fundraising_posts/views/edit_fundraising_post_view.dart';
import 'features/fundraising_posts/views/fundraising_post_details_view.dart';
import 'features/revisions/controllers/revisions_controller.dart';
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
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayoutView(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardView()),
        ),
        GoRoute(
          path: '/companies',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CompaniesView()),
        ),
        GoRoute(
          path: '/companies/add',
          builder: (context, state) => const AddCompanyView(),
        ),
        GoRoute(
          path: '/companies/view/:id',
          builder: (context, state) =>
              CompanyDetailsView(companyId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/companies/edit/:id',
          builder: (context, state) =>
              EditCompanyView(companyId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/investors',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: InvestorsView()),
        ),
        GoRoute(
          path: '/investors/add',
          builder: (context, state) => const AddInvestorView(),
        ),
        GoRoute(
          path: '/investors/view/:id',
          builder: (context, state) =>
              InvestorDetailsView(investorId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/investors/edit/:id',
          builder: (context, state) =>
              EditInvestorView(investorId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/members',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MembersView()),
        ),
        GoRoute(
          path: '/members/view/:id',
          builder: (context, state) =>
              MemberDetailsView(memberId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/members/edit/:id',
          builder: (context, state) =>
              EditMemberView(memberId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/packages',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PackagesView()),
        ),
        GoRoute(
          path: '/packages/add',
          builder: (context, state) => const AddPackageView(),
        ),
        GoRoute(
          path: '/packages/view/:id',
          builder: (context, state) =>
              PackageDetailsView(packageId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/founders',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FoundersView()),
        ),
        GoRoute(
          path: '/founders/add',
          builder: (context, state) => const AddFounderView(),
        ),
        GoRoute(
          path: '/founders/edit/:id',
          builder: (context, state) =>
              EditFounderView(founderId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/founders/view/:id',
          builder: (context, state) =>
              FounderDetailsView(founderId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/investments',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: InvestmentsView()),
        ),
        GoRoute(
          path: '/investments/add',
          builder: (context, state) => const AddInvestmentView(),
        ),
        GoRoute(
          path: '/investments/edit/:id',
          builder: (context, state) =>
              EditInvestmentView(investmentId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/investments/view/:id',
          builder: (context, state) =>
              InvestmentDetailsView(investmentId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/raises',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FundraisingPostsView()),
        ),
        GoRoute(
          path: '/raises/view/:slug',
          builder: (context, state) =>
              FundraisingPostDetailsView(slug: state.pathParameters['slug']!),
        ),
        GoRoute(
          path: '/raises/edit/:id',
          builder: (context, state) =>
              EditFundraisingPostView(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/packages/edit/:id',
          builder: (context, state) =>
              EditPackageView(packageId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/moderations',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ModerationsView()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsView()),
        ),
      ],
    ),
  ],
);
