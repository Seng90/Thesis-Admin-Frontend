import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/features/founders/models/founder_model.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class EditFounderView extends StatefulWidget {
  final String founderId;

  const EditFounderView({super.key, required this.founderId});

  @override
  State<EditFounderView> createState() => _EditFounderViewState();
}

class _EditFounderViewState extends State<EditFounderView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _linkedinController;
  
  Founder? _existingFounder;
  bool _isSaving = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<FoundersController>(context, listen: false);
      try {
        _existingFounder = controller.founders.firstWhere((f) => f.id == widget.founderId);
      } catch (_) {
        _existingFounder = null;
      }
      
      _nameController = TextEditingController(text: _existingFounder?.name ?? '');
      _bioController = TextEditingController(text: _existingFounder?.bio ?? '');
      _linkedinController = TextEditingController(text: _existingFounder?.linkedinUrl ?? '');
      
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final revController = Provider.of<RevisionsController>(context, listen: false);
    
    final proposedChanges = <String, dynamic>{};
    if (_nameController.text.trim() != _existingFounder?.name) {
      proposedChanges['name'] = _nameController.text.trim();
    }
    if (_bioController.text.trim() != _existingFounder?.bio) {
      proposedChanges['bio'] = _bioController.text.trim();
    }
    if (_linkedinController.text.trim() != _existingFounder?.linkedinUrl) {
      proposedChanges['linkedin_url'] = _linkedinController.text.trim();
    }

    if (proposedChanges.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made.')),
      );
      context.pop();
      return;
    }

    final success = await revController.createRevision(
      entityType: 'Founder',
      entityId: widget.founderId,
      proposedChanges: proposedChanges,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(revController.errorMessage ?? 'Failed to submit revision'), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit submitted for review!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_existingFounder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Founder')),
        body: const Center(child: Text('Founder not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Founder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Founder Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Founder Name *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Founder name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Additional Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _linkedinController,
                        decoration: const InputDecoration(
                          labelText: 'LinkedIn URL',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveForm,
                          icon: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Updating...' : 'Update Founder'),
                        ),
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
