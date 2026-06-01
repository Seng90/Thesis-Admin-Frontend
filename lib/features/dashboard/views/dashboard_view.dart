import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome back! Here is what is happening with your startups today.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Consumer2<CompaniesController, MembersController>(
              builder: (context, companiesCtrl, membersCtrl, child) {
                final totalCompanies = companiesCtrl.companies.length;
                final pendingApprovals = companiesCtrl.companies.where((c) => c.status == 'Pending').length;
                final totalMembers = membersCtrl.members.length;

                return Row(
                  children: [
                    _buildSummaryCard('Total Companies', totalCompanies.toString(), Icons.business, AppColors.primary, AppColors.primaryLight, 'Registered companies'),
                    const SizedBox(width: 24),
                    _buildSummaryCard('Pending Approvals', pendingApprovals.toString(), Icons.pending_actions, AppColors.warning, AppColors.warningBg, 'Needs your attention'),
                    const SizedBox(width: 24),
                    _buildSummaryCard('Total Members', totalMembers.toString(), Icons.people, AppColors.success, AppColors.successBg, 'Registered users'),
                  ],
                );
              },
            ),
            
            // Further dashboard content can go here
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color iconColor, Color iconBg, String subtitle) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                count,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
