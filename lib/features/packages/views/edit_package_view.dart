import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/packages_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/localizations.dart';

class EditPackageView extends StatefulWidget {
  final String packageId;

  const EditPackageView({super.key, required this.packageId});

  @override
  State<EditPackageView> createState() => _EditPackageViewState();
}

class FeatureItem {
  TextEditingController controller = TextEditingController();

  void dispose() {
    controller.dispose();
  }
}

class _EditPackageViewState extends State<EditPackageView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  final List<FeatureItem> _features = [];

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<PackagesController>(
        context,
        listen: false,
      );
      final existingPackage = controller.packages.firstWhere(
        (p) => p.id == widget.packageId,
      );

      _nameController = TextEditingController(text: existingPackage.name);
      _priceController = TextEditingController(
        text: existingPackage.price.toString(),
      );

      try {
        if (existingPackage.features.isNotEmpty) {
          final List<dynamic> parsed = jsonDecode(existingPackage.features);
          for (var itemValue in parsed) {
            final item = FeatureItem();
            item.controller.text = itemValue.toString();
            _features.add(item);
          }
        }
      } catch (e) {
        // If it's not JSON array, maybe it was object or comma separated
        try {
          final Map<String, dynamic> parsedMap = jsonDecode(
            existingPackage.features,
          );
          parsedMap.forEach((k, v) {
            final item = FeatureItem();
            item.controller.text = "$k: $v";
            _features.add(item);
          });
        } catch (e2) {
          final parts = existingPackage.features.split(',');
          for (var part in parts) {
            if (part.trim().isNotEmpty) {
              final item = FeatureItem();
              item.controller.text = part.trim();
              _features.add(item);
            }
          }
        }
      }
      if (_features.isEmpty) {
        _features.add(FeatureItem());
      }

      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    for (var f in _features) {
      f.dispose();
    }
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final controller = Provider.of<PackagesController>(
        context,
        listen: false,
      );
      final existingPackage = controller.packages.firstWhere(
        (p) => p.id == widget.packageId,
      );

      Map<String, dynamic> changes = {};

      if (_nameController.text != existingPackage.name) {
        changes['name'] = _nameController.text;
      }
      final newPrice = double.tryParse(_priceController.text) ?? 0;
      if (newPrice != existingPackage.price) {
        changes['price'] = newPrice;
      }

      List<String> featuresArray = [];
      for (var f in _features) {
        if (f.controller.text.trim().isNotEmpty) {
          featuresArray.add(f.controller.text.trim());
        }
      }
      final newFeaturesJson = jsonEncode(featuresArray);

      if (newFeaturesJson != existingPackage.features) {
        changes['features'] = newFeaturesJson;
      }

      if (changes.isNotEmpty) {
        final revisionsController = Provider.of<RevisionsController>(
          context,
          listen: false,
        );
        revisionsController.createRevision(
          entityType: 'Package',
          entityId: widget.packageId,
          proposedChanges: changes,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit submitted for review!'.tr(context, listen: false))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No changes detected.'.tr(context, listen: false))),
        );
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Package'),
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
                        child: const Text('Update Package'),
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
