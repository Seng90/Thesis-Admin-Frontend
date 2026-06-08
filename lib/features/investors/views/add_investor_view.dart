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
  String _type = 'Venture Capital';

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final revisionsController = Provider.of<RevisionsController>(context, listen: false);
      
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

      final success = await revisionsController.createRevision(
        entityType: 'Investor',
        entityId: null,
        proposedChanges: proposedChanges,
      );

      if (mounted) {
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(revisionsController.errorMessage ?? 'Failed to submit revision')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Investor creation submitted for review!')),
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
                        decoration: const InputDecoration(labelText: 'Investor Name'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: ['Venture Capital', 'Angel Investor', 'Private Equity'].map((String val) {
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
                        decoration: const InputDecoration(labelText: 'Website URL (Optional)'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Contact Email/Phone'),
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
