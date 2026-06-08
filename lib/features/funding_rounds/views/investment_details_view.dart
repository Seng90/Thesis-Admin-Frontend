import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';

class InvestmentDetailsView extends StatefulWidget {
  final String investmentId;
  const InvestmentDetailsView({super.key, required this.investmentId});

  @override
  State<InvestmentDetailsView> createState() => _InvestmentDetailsViewState();
}

class _InvestmentDetailsViewState extends State<InvestmentDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvestmentsController>(context, listen: false).fetchInvestments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<InvestmentsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          
          try {
            final inv = controller.investments.firstWhere((i) => i.id == widget.investmentId);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${inv.amount} ${inv.currency}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Company ID: ${inv.companyId}'),
                      const SizedBox(height: 12),
                      Text('Investor ID: ${inv.investorId}'),
                      const SizedBox(height: 12),
                      Text('Round ID: ${inv.roundId}'),
                      const SizedBox(height: 12),
                      Text('Date: ${inv.investDate.toIso8601String()}'),
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            return const Center(child: Text('Investment not found'));
          }
        }
      ),
    );
  }
}
