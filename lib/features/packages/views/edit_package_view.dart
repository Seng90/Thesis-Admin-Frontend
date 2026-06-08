import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/packages/controllers/packages_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/localizations.dart';


class EditPackageView extends StatefulWidget {
  final String packageId;

  const EditPackageView({super.key, required this.packageId});

  @override
  State<EditPackageView> createState() => _EditPackageViewState();
}

class _EditPackageViewState extends State<EditPackageView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _featuresController;
  
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<PackagesController>(context, listen: false);
      final existingPackage = controller.packages.firstWhere((p) => p.id == widget.packageId);
      
      _nameController = TextEditingController(text: existingPackage.name);
      _priceController = TextEditingController(text: existingPackage.price.toString());
      _featuresController = TextEditingController(text: existingPackage.features);
      
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final controller = Provider.of<PackagesController>(context, listen: false);
      final existingPackage = controller.packages.firstWhere((p) => p.id == widget.packageId);
          
      Map<String, dynamic> changes = {};
      
      if (_nameController.text != existingPackage.name) {
        changes['name'] = _nameController.text;
      }
      final newPrice = double.tryParse(_priceController.text) ?? 0;
      if (newPrice != existingPackage.price) {
        changes['price'] = newPrice;
      }
      if (_featuresController.text != existingPackage.features) {
        changes['features'] = _featuresController.text;
      }

      if (changes.isNotEmpty) {
        final revisionsController = Provider.of<RevisionsController>(context, listen: false);
        revisionsController.createRevision(
          entityType: 'Package',
          entityId: widget.packageId,
          proposedChanges: changes,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit submitted for review!'.tr(context))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No changes detected.'.tr(context))),
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
