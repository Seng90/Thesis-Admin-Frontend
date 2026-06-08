import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class FoundersView extends StatefulWidget {
  const FoundersView({super.key});

  @override
  State<FoundersView> createState() => _FoundersViewState();
}

class _FoundersViewState extends State<FoundersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoundersController>(context, listen: false).fetchFounders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoundersController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage!, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchFounders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Founders'),
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Founder'),
                onPressed: () => context.push('/founders/add'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: controller.founders.isEmpty
              ? const Center(child: Text('No founders found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: controller.founders.length,
                  itemBuilder: (context, index) {
                    final founder = controller.founders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(founder.name.isNotEmpty ? founder.name[0].toUpperCase() : '?'),
                        ),
                        title: Text(founder.name),
                        subtitle: Text(founder.bio ?? 'No bio'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () => context.push('/founders/edit/${founder.id}'),
                        ),
                        onTap: () => context.push('/founders/view/${founder.id}'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
