import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';

class AddPackageView extends StatefulWidget {
  const AddPackageView({super.key});

  @override
  State<AddPackageView> createState() => _AddPackageViewState();
}

class FeatureItem {
  TextEditingController controller = TextEditingController();

  void dispose() {
    controller.dispose();
  }
}

class _AddPackageViewState extends State<AddPackageView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final List<FeatureItem> _features = [FeatureItem()];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    for (var f in _features) {
      f.dispose();
    }
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final revisionsController = Provider.of<RevisionsController>(
        context,
        listen: false,
      );

      List<String> featuresArray = [];
      for (var f in _features) {
        if (f.controller.text.trim().isNotEmpty) {
          featuresArray.add(f.controller.text.trim());
        }
      }
      final featuresJson = jsonEncode(featuresArray);

      Map<String, dynamic> proposedChanges = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'duration_days': int.tryParse(_durationController.text),
        'features': featuresJson,
      };

      final success = await revisionsController.createRevision(
        entityType: 'Package',
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
              content: Text('Package creation submitted for review!'),
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
                        decoration: const InputDecoration(
                          labelText: 'Package Name (e.g. Premium)',
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (USD)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration in Days (Leave blank for Lifetime)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Features',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._features.asMap().entries.map((entry) {
                        int idx = entry.key;
                        FeatureItem item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.controller,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Feature (e.g. Max 10 Investors)',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  if (_features.length > 1) {
                                    setState(() {
                                      _features.removeAt(idx);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _features.add(FeatureItem());
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Feature'),
                        ),
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
