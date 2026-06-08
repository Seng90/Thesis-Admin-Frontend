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
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  
  Founder? _existingFounder;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFounder();
    });
  }

  void _loadFounder() {
    final controller = Provider.of<FoundersController>(context, listen: false);
    try {
      final found = controller.founders.firstWhere((f) => f.id == widget.founderId);
      setState(() {
        _existingFounder = found;
        _nameController.text = found.name;
        _bioController.text = found.bio ?? '';
        _linkedinController.text = found.linkedinUrl ?? '';
      });
    } catch (e) {
      // Not found
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
    final revisionsController = Provider.of<RevisionsController>(context, listen: false);
    
    Map<String, dynamic> proposedChanges = {};
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes made.')));
      context.pop();
      return;
    }

    final success = await revisionsController.createRevision(
      entityType: 'Founder',
      entityId: widget.founderId,
      proposedChanges: proposedChanges,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(revisionsController.errorMessage ?? 'Failed to submit revision'), backgroundColor: AppColors.error),
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Founder Name *'),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(labelText: 'Bio'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _linkedinController,
                        decoration: const InputDecoration(labelText: 'LinkedIn URL'),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveForm,
                          child: _isSaving 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Submit Edit'),
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
