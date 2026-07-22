const fs = require('fs');

const filepath = 'D:/Thesis Project InvesTrack/investrack_admin/lib/features/members/views/members_view.dart';
let content = fs.readFileSync(filepath, 'utf8');

// 1. Add import
content = content.replace(
    "import '../controllers/members_controller.dart';",
    "import '../controllers/members_controller.dart';\nimport 'package:investrack_admin/features/packages/controllers/packages_controller.dart';"
);

// 2. Add PackagesController init
const old_init = `    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MembersController>(context, listen: false);
      if (controller.members.isEmpty && !controller.isLoading) {
        controller.loadMembers();
      }
    });`;
const new_init = `    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MembersController>(context, listen: false);
      if (controller.members.isEmpty && !controller.isLoading) {
        controller.loadMembers();
      }
      final pkgController = Provider.of<PackagesController>(context, listen: false);
      if (pkgController.packages.isEmpty && !pkgController.isLoading) {
        pkgController.loadPackages();
      }
    });`;
content = content.replace(old_init, new_init);

// 3. Remove Sync Expiry
const sync_btn = `            Consumer<MembersController>(
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
            ),`;
content = content.replace(sync_btn, "");

// 4. Replace Expiry display
const old_expiry = `                                                  DataCell(
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
                                                  ),`;
const new_expiry = `                                                  DataCell(
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
                                                  ),`;
content = content.replace(old_expiry, new_expiry);

fs.writeFileSync(filepath, content, 'utf8');
console.log('Done');
