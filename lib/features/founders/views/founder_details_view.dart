import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';


class FounderDetailsView extends StatefulWidget {
  final String founderId;
  const FounderDetailsView({super.key, required this.founderId});

  @override
  State<FounderDetailsView> createState() => _FounderDetailsViewState();
}

class _FounderDetailsViewState extends State<FounderDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoundersController>(context, listen: false).fetchFounders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Founder Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<FoundersController>(
        builder: (context, controller, child) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          
          try {
            final founder = controller.founders.firstWhere((f) => f.id == widget.founderId);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${founder.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Bio: ${founder.bio ?? "N/A"}'),
                      const SizedBox(height: 12),
                      Text('LinkedIn: ${founder.linkedinUrl ?? "N/A"}'),
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            return const Center(child: Text('Founder not found'));
          }
        }
      ),
    );
  }
}
