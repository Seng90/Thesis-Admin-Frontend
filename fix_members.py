import re
import sys

def modify_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add import
    content = content.replace(
        "import '../controllers/members_controller.dart';",
        "import '../controllers/members_controller.dart';\nimport 'package:investrack_admin/features/packages/controllers/packages_controller.dart';"
    )

    # 2. Add PackagesController init
    init_str = """    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MembersController>(context, listen: false);
      if (controller.members.isEmpty && !controller.isLoading) {
        controller.loadMembers();
      }
      final pkgController = Provider.of<PackagesController>(context, listen: false);
      if (pkgController.packages.isEmpty && !pkgController.isLoading) {
        pkgController.loadPackages();
      }
    });"""
    content = re.sub(r'    WidgetsBinding\.instance\.addPostFrameCallback\(\(\_\) \{.*?\n      \}\n    \}\);', init_str, content, flags=re.DOTALL)
    
    # Wait, the regex might fail. Let's just do a simple replace.
    old_init = """    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MembersController>(context, listen: false);
      if (controller.members.isEmpty && !controller.isLoading) {
        controller.loadMembers();
      }
    });"""
    new_init = """    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MembersController>(context, listen: false);
      if (controller.members.isEmpty && !controller.isLoading) {
        controller.loadMembers();
      }
      final pkgController = Provider.of<PackagesController>(context, listen: false);
      if (pkgController.packages.isEmpty && !pkgController.isLoading) {
        pkgController.loadPackages();
      }
    });"""
    content = content.replace(old_init, new_init)

    # 3. Remove Sync Expiry
    sync_btn = """            Consumer<MembersController>(
              builder: (context, controller, child) {
                return TextButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final success = await controller.checkExpiry();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Expirations checked and synced successfully!'
                                            .tr(context, listen: false)
                                      : (controller.errorMessage ??
                                            'Failed to sync expirations.'.tr(
                                              context,
                                              listen: false,
                                            )),
                                ),
                                backgroundColor: success
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.sync),
                  label: Text('Sync Expiry'.tr(context)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                );
              },
            ),"""
    content = content.replace(sync_btn, "")
    
    # 4. Replace Expiry display
    old_expiry = """                                                  DataCell(
                                                    Text(
                                                      member.expiryDate
                                                              ?.toString()
                                                              .split(' ')[0] ??
                                                          'Lifetime',
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),"""
    new_expiry = """                                                  DataCell(
                                                    Consumer<PackagesController>(
                                                      builder: (context, pkgCtrl, child) {
                                                        final package = pkgCtrl.packages.where((p) => p.id == member.packageId).firstOrNull;
                                                        final isFree = package == null || package.price == 0;
                                                        
                                                        return Text(
                                                          isFree 
                                                              ? '-' 
                                                              : member.expiryDate
                                                                  ?.toString()
                                                                  .split(' ')[0] ??
                                                              'Lifetime',
                                                          style: const TextStyle(
                                                            color: AppColors
                                                                .textSecondary,
                                                          ),
                                                        );
                                                      }
                                                    ),
                                                  ),"""
    content = content.replace(old_expiry, new_expiry)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

modify_file('D:/Thesis Project InvesTrack/investrack_admin/lib/features/members/views/members_view.dart')
