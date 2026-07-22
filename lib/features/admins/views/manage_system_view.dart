import 'package:flutter/material.dart';
import 'package:investrack_admin/widgets/admin_header.dart';
import 'package:investrack_admin/features/admins/views/admins_view.dart';
import 'package:investrack_admin/features/admins/views/roles_permissions_view.dart';

class ManageSystemView extends StatefulWidget {
  const ManageSystemView({super.key});

  @override
  State<ManageSystemView> createState() => _ManageSystemViewState();
}

class _ManageSystemViewState extends State<ManageSystemView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AdminHeader(
            title: 'Manage Base System & Admin',
          ),
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.admin_panel_settings),
                  text: 'Admin Accounts',
                ),
                Tab(
                  icon: Icon(Icons.security),
                  text: 'Roles & Permissions',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AdminsView(),
                RolesPermissionsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
