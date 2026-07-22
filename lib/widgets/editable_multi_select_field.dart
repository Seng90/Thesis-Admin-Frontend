import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:investrack_admin/utils/constants.dart';

class EditableMultiSelectField extends StatefulWidget {
  final String label;
  final String storageKey;
  final List<String> defaultOptions;
  final List<String> initialValues;
  final ValueChanged<List<String>> onChanged;

  const EditableMultiSelectField({
    super.key,
    required this.label,
    required this.storageKey,
    this.defaultOptions = const [],
    this.initialValues = const [],
    required this.onChanged,
  });

  @override
  State<EditableMultiSelectField> createState() => _EditableMultiSelectFieldState();
}

class _EditableMultiSelectFieldState extends State<EditableMultiSelectField> {
  List<String> _options = [];
  final Set<String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _selectedOptions.addAll(widget.initialValues);
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(widget.storageKey);
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _options = saved;
      });
    } else {
      setState(() {
        _options = List.from(widget.defaultOptions);
      });
      _saveOptions();
    }
  }

  Future<void> _saveOptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widget.storageKey, _options);
  }

  void _showManageOptionsDialog() {
    final TextEditingController newOptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Manage ${widget.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newOptionController,
                            decoration: const InputDecoration(
                              labelText: 'New Option',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty && !_options.contains(val.trim())) {
                                setState(() {
                                  _options.add(val.trim());
                                  _saveOptions();
                                });
                                setDialogState(() {});
                                newOptionController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final val = newOptionController.text.trim();
                            if (val.isNotEmpty && !_options.contains(val)) {
                              setState(() {
                                _options.add(val);
                                _saveOptions();
                              });
                              setDialogState(() {});
                              newOptionController.clear();
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_options.isEmpty)
                      const Text(
                        'No options available.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _options.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final opt = _options[index];
                            return ListTile(
                              dense: true,
                              title: Text(opt, style: const TextStyle(fontWeight: FontWeight.w500)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                tooltip: 'Delete option',
                                onPressed: () {
                                  setState(() {
                                    _options.removeAt(index);
                                    _selectedOptions.remove(opt);
                                    widget.onChanged(_selectedOptions.toList());
                                    _saveOptions();
                                  });
                                  setDialogState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleOption(String option, bool selected) {
    setState(() {
      if (selected) {
        _selectedOptions.add(option);
      } else {
        _selectedOptions.remove(option);
      }
    });
    widget.onChanged(_selectedOptions.toList());
  }

  @override
  Widget build(BuildContext context) {
    // Add missing options to the list if they are selected but not in the options list.
    for (final val in _selectedOptions) {
      if (!_options.contains(val)) {
        _options.add(val);
        _saveOptions(); // Fire and forget
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _showManageOptionsDialog,
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('Manage Options', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_options.isEmpty)
          const Text(
            'No options available. Click "Manage Options" to add some.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((opt) {
              final isSelected = _selectedOptions.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (selected) => _toggleOption(opt, selected),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
