import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';

class AddInvestorView extends StatefulWidget {
  const AddInvestorView({super.key});

  @override
  State<AddInvestorView> createState() => _AddInvestorViewState();
}

class _AddInvestorViewState extends State<AddInvestorView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _contactController = TextEditingController();
  final _focusController = TextEditingController();
  final _stagesController = TextEditingController();
  final _industriesController = TextEditingController();
  String _type = 'VC';

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _contactController.dispose();
    _focusController.dispose();
    _stagesController.dispose();
    _industriesController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final revisionsController = Provider.of<RevisionsController>(
        context,
        listen: false,
      );

      Map<String, dynamic> proposedChanges = {
        'name': _nameController.text,
        'type': _type,
      };

      if (_websiteController.text.isNotEmpty) {
        proposedChanges['website_url'] = _websiteController.text;
      }
      if (_contactController.text.isNotEmpty) {
        proposedChanges['contact_info'] = _contactController.text;
      }
      if (_focusController.text.isNotEmpty) {
        proposedChanges['investment_focus'] = _focusController.text;
      }
      if (_stagesController.text.isNotEmpty) {
        proposedChanges['preferred_stages'] = _stagesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (_industriesController.text.isNotEmpty) {
        proposedChanges['preferred_industries'] = _industriesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      final success = await revisionsController.createRevision(
        entityType: 'Investor',
        entityId: null,
        proposedChanges: proposedChanges,
      );

      if (mounted) {
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                revisionsController.errorMessage ?? 'Failed to submit revision',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Investor creation submitted for review!'),
            ),
          );
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Investor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Investor Name',
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items:
                            [
                              'VC',
                              'Angel',
                              'PE',
                              'Corporate',
                              'Accelerator',
                              'Syndicate',
                              'Other',
                            ].map((String val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                        onChanged: (newVal) {
                          setState(() {
                            _type = newVal!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website URL (Optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email/Phone',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _focusController,
                        decoration: const InputDecoration(
                          labelText: 'Investment Focus',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stagesController,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Stages (comma-separated, e.g. Pre-seed, Seed)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _industriesController,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Industries (comma-separated, e.g. FinTech, EdTech)',
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveForm,
                        child: const Text('Save Investor'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
