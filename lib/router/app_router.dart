import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:investrack_admin/features/auth/controllers/auth_controller.dart';
import 'package:investrack_admin/features/auth/views/login_view.dart';
import 'package:investrack_admin/features/companies/views/companies_view.dart';
import 'package:investrack_admin/features/companies/views/add_company_view.dart';
import 'package:investrack_admin/features/companies/views/edit_company_view.dart';
import 'package:investrack_admin/features/companies/views/company_details_view.dart';
import 'package:investrack_admin/features/dashboard/views/dashboard_view.dart';
import 'package:investrack_admin/features/dashboard/views/main_layout_view.dart';
import 'package:investrack_admin/features/investors/views/investors_view.dart';
import 'package:investrack_admin/features/investors/views/add_investor_view.dart';
import 'package:investrack_admin/features/investors/views/edit_investor_view.dart';
import 'package:investrack_admin/features/investors/views/investor_details_view.dart';
import 'package:investrack_admin/features/members/views/members_view.dart';
import 'package:investrack_admin/features/members/views/edit_member_view.dart';
import 'package:investrack_admin/features/members/views/member_details_view.dart';
import 'package:investrack_admin/features/revisions/views/moderations_view.dart';
import 'package:investrack_admin/features/packages/views/packages_view.dart';
import 'package:investrack_admin/features/packages/views/add_package_view.dart';
import 'package:investrack_admin/features/packages/views/edit_package_view.dart';
import 'package:investrack_admin/features/packages/views/package_details_view.dart';
import 'package:investrack_admin/features/founders/views/founders_view.dart';
import 'package:investrack_admin/features/founders/views/add_founder_view.dart';
import 'package:investrack_admin/features/founders/views/edit_founder_view.dart';
import 'package:investrack_admin/features/founders/views/founder_details_view.dart';
import 'package:investrack_admin/features/funding_rounds/views/investments_view.dart';
import 'package:investrack_admin/features/funding_rounds/views/add_investment_view.dart';
import 'package:investrack_admin/features/funding_rounds/views/edit_investment_view.dart';
import 'package:investrack_admin/features/funding_rounds/views/investment_details_view.dart';
import 'package:investrack_admin/features/funding_rounds/views/investment_summary_detail_view.dart';
import 'package:investrack_admin/features/fundraising_posts/views/fundraising_posts_view.dart';
import 'package:investrack_admin/features/fundraising_posts/views/edit_fundraising_post_view.dart';
import 'package:investrack_admin/features/fundraising_posts/views/fundraising_post_details_view.dart';
import 'package:investrack_admin/features/settings/views/settings_view.dart';

GoRouter createAppRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authController,
    redirect: (context, state) {
      final isAuthenticated = authController.isAuthenticated;
      final isCheckingAuth = authController.isCheckingAuth;
      final stateUri = state.uri.toString();

      if (isCheckingAuth) {
        return '/splash';
      }

      if (!isAuthenticated) {
        return stateUri == '/login' ? null : '/login';
      }

      if (stateUri == '/login' || stateUri == '/splash') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
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
            builder: (context, state) => AddInvestmentView(
              initialCompanyId: state.uri.queryParameters['companyId'],
              initialRoundId: state.uri.queryParameters['roundId'],
            ),
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
            path: '/investments/summary/:idx',
            builder: (context, state) => InvestmentSummaryDetailView(
              summaryIndex: int.tryParse(state.pathParameters['idx'] ?? '0') ?? 0,
            ),
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
}
