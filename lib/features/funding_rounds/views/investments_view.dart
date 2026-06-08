import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class InvestmentsView extends StatefulWidget {
  const InvestmentsView({super.key});

  @override
  State<InvestmentsView> createState() => _InvestmentsViewState();
}

class _InvestmentsViewState extends State<InvestmentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvestmentsController>(context, listen: false).fetchInvestments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvestmentsController>(
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
                  onPressed: () => controller.fetchInvestments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Investments'),
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Investment'),
                onPressed: () => context.push('/investments/add'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: controller.investments.isEmpty
              ? const Center(child: Text('No investments found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: controller.investments.length,
                  itemBuilder: (context, index) {
                    final inv = controller.investments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(inv.currency),
                        ),
                        title: Text('Amount: ${inv.amount} ${inv.currency}'),
                        subtitle: Text('Date: ${inv.investDate.toString().split(' ')[0]}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () => context.push('/investments/edit/${inv.id}'),
                        ),
                        onTap: () => context.push('/investments/view/${inv.id}'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
