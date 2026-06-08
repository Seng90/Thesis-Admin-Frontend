import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';

class AddPackageView extends StatefulWidget {
  const AddPackageView({super.key});

  @override
  State<AddPackageView> createState() => _AddPackageViewState();
}

class _AddPackageViewState extends State<AddPackageView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _featuresController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final revisionsController = Provider.of<RevisionsController>(context, listen: false);
          
      Map<String, dynamic> proposedChanges = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'features': _featuresController.text,
      };

      final success = await revisionsController.createRevision(
        entityType: 'Package',
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
            const SnackBar(content: Text('Package creation submitted for review!')),
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
        title: const Text('Add New Package'),
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
                        decoration: const InputDecoration(labelText: 'Package Name (e.g. Premium)'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price (LAK)'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _featuresController,
                        decoration: const InputDecoration(labelText: 'Features (comma separated)'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveForm,
                        child: const Text('Save Package'),
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
