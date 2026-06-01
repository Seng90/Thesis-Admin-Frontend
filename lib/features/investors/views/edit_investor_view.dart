import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/features/investors/models/investor_model.dart';
import 'package:investrack_admin/utils/localizations.dart';

class EditInvestorView extends StatefulWidget {
  final String investorId;

  const EditInvestorView({super.key, required this.investorId});

  @override
  State<EditInvestorView> createState() => _EditInvestorViewState();
}

class _EditInvestorViewState extends State<EditInvestorView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _websiteController;
  late TextEditingController _contactController;
  late TextEditingController _logoUrlController;
  late String _type;
  
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<InvestorsController>(context, listen: false);
      final existingInvestor = controller.investors.firstWhere((i) => i.id == widget.investorId);
      
      _nameController = TextEditingController(text: existingInvestor.name);
      _websiteController = TextEditingController(text: existingInvestor.websiteUrl ?? '');
      _contactController = TextEditingController(text: existingInvestor.contactInfo ?? '');
      _logoUrlController = TextEditingController(text: existingInvestor.logoUrl ?? '');
      _type = existingInvestor.type;
      
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _contactController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final controller = Provider.of<InvestorsController>(context, listen: false);
      final existingInvestor = controller.investors.firstWhere((i) => i.id == widget.investorId);
      
      final investor = Investor(
        id: widget.investorId,
        name: _nameController.text,
        type: _type,
        logoUrl: _logoUrlController.text.isNotEmpty ? _logoUrlController.text : null,
        websiteUrl: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        contactInfo: _contactController.text.isNotEmpty ? _contactController.text : null,
        createdAt: existingInvestor.createdAt,
      );

      controller.updateInvestor(investor);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Investor'.tr(context)),
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
                          if (newVal != null) {
                            setState(() {
                              _type = newVal;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _logoUrlController,
                        decoration: const InputDecoration(labelText: 'Logo URL'),
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
                        child: Text('Update Investor'.tr(context)),
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
