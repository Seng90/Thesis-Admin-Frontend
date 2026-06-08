import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';
import 'package:investrack_admin/features/packages/controllers/packages_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';

import 'package:investrack_admin/utils/localizations.dart';

class EditMemberView extends StatefulWidget {
  final String memberId;

  const EditMemberView({super.key, required this.memberId});

  @override
  State<EditMemberView> createState() => _EditMemberViewState();
}

class _EditMemberViewState extends State<EditMemberView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late String _status;
  String? _packageId;
  DateTime? _expiryDate;
  
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<MembersController>(context, listen: false);
      final existingMember = controller.members.firstWhere((m) => m.id == widget.memberId);
      
      _usernameController = TextEditingController(text: existingMember.username);
      _emailController = TextEditingController(text: existingMember.email);
      _status = existingMember.status;
      _packageId = existingMember.packageId;
      _expiryDate = existingMember.expiryDate;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<PackagesController>(context, listen: false).loadPackages();
      });
      
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final controller = Provider.of<MembersController>(context, listen: false);
      final existingMember = controller.members.firstWhere((m) => m.id == widget.memberId);
      
      Map<String, dynamic> changes = {};
      
      if (_usernameController.text != existingMember.username) {
        changes['username'] = _usernameController.text;
      }
      if (_emailController.text != existingMember.email) {
        changes['email'] = _emailController.text;
      }
      if (_status != existingMember.status) {
        changes['status'] = _status;
      }
      if (_packageId != existingMember.packageId) {
        changes['packageId'] = _packageId;
      }
      if (_expiryDate != existingMember.expiryDate) {
        changes['expiryDate'] = _expiryDate?.toIso8601String();
      }

      if (changes.isNotEmpty) {
        final revisionsController = Provider.of<RevisionsController>(context, listen: false);
        revisionsController.createRevision(
          entityType: 'Member',
          entityId: widget.memberId,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagesController = Provider.of<PackagesController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Member'.tr(context)),
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
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'.tr(context)),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'.tr(context)),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: InputDecoration(labelText: 'Status'.tr(context)),
                        items: ['Active', 'Blocked'].map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _status = newVal;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: _packageId,
                        decoration: InputDecoration(labelText: 'Package'.tr(context)),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('None (Lifetime)')),
                          ...packagesController.packages.map((pkg) {
                            return DropdownMenuItem(
                              value: pkg.id,
                              child: Text(pkg.name),
                            );
                          }),
                        ],
                        onChanged: (newVal) {
                          setState(() {
                            _packageId = newVal;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Expiry Date'.tr(context)),
                        subtitle: Text(_expiryDate != null 
                            ? _expiryDate!.toString().split(' ')[0] 
                            : 'Lifetime'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveForm,
                        child: Text('Save Changes'.tr(context)),
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
