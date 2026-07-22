import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/auth/controllers/auth_controller.dart';
import 'package:investrack_admin/features/settings/controllers/settings_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final settingsController = Provider.of<SettingsController>(context);
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (user != null && user.roles.contains('super_admin'))
                      ElevatedButton.icon(
                        onPressed: () => context.push('/admins'),
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Manage Base System & Admin'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            (user?.username ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.username ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user != null && user.roles.isNotEmpty
                                      ? user.roles.join(', ')
                                      : 'No Role',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ID: ${user?.id ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),



                // Preferences Section
                const Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Notifications'),
                        subtitle: const Text(
                          'Receive alerts for new company submissions',
                        ),
                        value: _notificationsEnabled,
                        onChanged: (val) {
                          setState(() {
                            _notificationsEnabled = val;
                          });
                        },
                        activeThumbColor: AppColors.primary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Switch to dark theme'),
                        value: settingsController.isDarkMode,
                        onChanged: (val) {
                          settingsController.toggleDarkMode(val);
                        },
                        activeThumbColor: AppColors.primary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Language',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Select application language',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color ??
                                        AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
                              value: settingsController.languageCode,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: 'lo',
                                  child: Text('ພາສາລາວ'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  settingsController.setLanguage(val);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        val == 'lo'
                                            ? 'ປ່ຽນເປັນພາສາລາວແລ້ວ (ມີຜົນບາງສ່ວນ)'
                                            : 'Language changed to English',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // System Info Section
                const Text(
                  'System Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildInfoRow('Application', AppConstants.appName),
                        const Divider(height: 24),
                        _buildInfoRow('Version', '1.0.0'),
                        const Divider(height: 24),
                        _buildInfoRow('Backend', 'NestJS + Prisma'),
                        const Divider(height: 24),
                        _buildInfoRow('Database', 'PostgreSQL'),
                        const Divider(height: 24),
                        _buildInfoRow('Framework', 'Flutter'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Danger Zone
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Logout',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Sign out of your admin account and return to the login screen.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirm Logout'),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      authController.logout();
                                      context.go('/login');
                                    },
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
