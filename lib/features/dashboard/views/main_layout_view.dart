import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/auth/controllers/auth_controller.dart';

class MainLayoutView extends StatefulWidget {
  final Widget child;

  const MainLayoutView({super.key, required this.child});

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    int selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);
    
    // Attempt to get admin info if available
    String adminInitials = 'AD';
    String adminName = 'Admin';
    try {
      final auth = Provider.of<AuthController>(context, listen: false).currentAdmin;
      if (auth != null) {
        adminName = auth.username;
        if (adminName.isNotEmpty) {
          adminInitials = adminName.substring(0, 1).toUpperCase();
        }
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarCollapsed ? 80 : 250,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 1)),
            ),
            child: Column(
              children: [
                // Logo & Toggle Area
                Padding(
                  padding: EdgeInsets.all(_isSidebarCollapsed ? 16.0 : 24.0),
                  child: Row(
                    mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.insights, color: AppColors.primary),
                      ),
                      if (!_isSidebarCollapsed) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'InvesTrack',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Toggle Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: _isSidebarCollapsed ? Alignment.center : Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(_isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left, color: AppColors.textSecondary),
                      onPressed: () {
                        setState(() {
                          _isSidebarCollapsed = !_isSidebarCollapsed;
                        });
                      },
                      tooltip: _isSidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Navigation Links
                _buildNavItem(context, 'Dashboard'.tr(context), Icons.dashboard_outlined, Icons.dashboard, 0, selectedIndex, '/dashboard'),
                _buildNavItem(context, 'Companies'.tr(context), Icons.business_outlined, Icons.business, 1, selectedIndex, '/companies'),
                _buildNavItem(context, 'Investors'.tr(context), Icons.attach_money_outlined, Icons.attach_money, 2, selectedIndex, '/investors'),
                _buildNavItem(context, 'Members'.tr(context), Icons.person_outline, Icons.person, 3, selectedIndex, '/members'),
                _buildNavItem(context, 'Packages'.tr(context), Icons.card_membership_outlined, Icons.card_membership, 4, selectedIndex, '/packages'),
                
                const Spacer(),
                
                _buildNavItem(context, 'Settings'.tr(context), Icons.settings_outlined, Icons.settings, 5, selectedIndex, '/settings'),
                
                // Profile & Logout Area
                Divider(color: theme.dividerColor.withValues(alpha: 0.1), height: 1),
                Padding(
                  padding: EdgeInsets.all(_isSidebarCollapsed ? 16.0 : 16.0),
                  child: _isSidebarCollapsed
                      ? Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(adminInitials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),
                            IconButton(
                              icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                              onPressed: () => _showLogoutDialog(context),
                              tooltip: 'Logout'.tr(context),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(adminInitials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text('Admin', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                              onPressed: () => _showLogoutDialog(context),
                              tooltip: 'Logout'.tr(context),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Logout'.tr(context)),
        content: Text('Are you sure you want to logout?'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: Text('Logout'.tr(context), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, IconData activeIcon, int index, int selectedIndex, String route) {
    final isSelected = index == selectedIndex;
    
    Widget navContent = Container(
      padding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 0 : 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
          if (!_isSidebarCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    if (_isSidebarCollapsed) {
      navContent = Tooltip(
        message: title,
        preferBelow: false,
        child: navContent,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(8),
        child: navContent,
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/companies')) return 1;
    if (location.startsWith('/investors')) return 2;
    if (location.startsWith('/members')) return 3;
    if (location.startsWith('/packages')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0;
  }
}
