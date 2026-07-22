const fs = require('fs');

function fixAddCompany() {
    const path = 'D:\\Thesis Project InvesTrack\\investrack_admin\\lib\\features\\companies\\views\\add_company_view.dart';
    let content = fs.readFileSync(path, 'utf8');

    // 1. Add _selectedIndustry, _industries
    content = content.replace(
        "final _industryController = TextEditingController();",
        "String? _selectedIndustry;\n  List<String> _industries = [\n    'FinTech',\n    'HealthTech',\n    'EdTech',\n    'E-commerce',\n    'SaaS',\n    'AI & Data',\n  ];"
    );

    // 2. Change _employeeCountOptions to List<String>
    content = content.replace(
        "static const List<String> _employeeCountOptions = [",
        "List<String> _employeeCountOptions = ["
    );

    // 3. Add initState and load/save methods
    const initState = `
  @override
  void initState() {
    super.initState();
    _loadIndustries();
    _loadEmployeeCounts();
  }

  Future<void> _loadIndustries() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('admin_industries');
    if (saved != null && saved.isNotEmpty) {
      if (mounted) setState(() => _industries = saved);
    }
  }

  Future<void> _saveIndustries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('admin_industries', _industries);
  }

  Future<void> _loadEmployeeCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('admin_employee_counts');
    if (saved != null && saved.isNotEmpty) {
      if (mounted) {
        setState(() {
          _employeeCountOptions = saved;
          if (_employeeCount != null && !_employeeCountOptions.contains(_employeeCount!)) {
            _employeeCountOptions.add(_employeeCount!);
          }
        });
      }
    } else {
      if (mounted && _employeeCount != null && !_employeeCountOptions.contains(_employeeCount!)) {
        setState(() {
          _employeeCountOptions.add(_employeeCount!);
        });
      }
    }
  }

  Future<void> _saveEmployeeCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('admin_employee_counts', _employeeCountOptions);
  }

  @override
  void dispose() {`;
    content = content.replace("  @override\n  void dispose() {", initState);
    content = content.replace("  @override\r\n  void dispose() {", initState);

    // 4. Remove _industryController.dispose()
    content = content.replace(/    _industryController\.dispose\(\);\r?\n/g, "");

    // 5. Add shared_preferences import
    if (!content.includes("shared_preferences")) {
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:shared_preferences/shared_preferences.dart';");
    }

    // 6. Change saving logic for industry
    content = content.replace(
        "      'industry': _industryController.text.trim(),",
        "      if (_selectedIndustry != null)\n        'industry': _selectedIndustry,"
    );
    // Also need validation check
    const saveFormOld = "  Future<void> _saveForm() async {\n    if (!_formKey.currentState!.validate()) return;\n";
    const saveFormOldCRLF = "  Future<void> _saveForm() async {\r\n    if (!_formKey.currentState!.validate()) return;\r\n";
    const saveFormNew = "  Future<void> _saveForm() async {\n    if (!_formKey.currentState!.validate()) return;\n    if (_selectedIndustry == null) {\n      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an industry')));\n      return;\n    }\n";
    content = content.replace(saveFormOld, saveFormNew);
    content = content.replace(saveFormOldCRLF, saveFormNew);

    // 7. Add Manage Dialogs before build
    const dialogs = `
  void _showManageIndustriesDialog() {
    final newIndController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Industries', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            controller: newIndController,
                            decoration: const InputDecoration(
                              labelText: 'New Industry',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final val = newIndController.text.trim();
                            if (val.isNotEmpty && !_industries.contains(val)) {
                              setState(() {
                                _industries.add(val);
                                _saveIndustries();
                              });
                              setDialogState(() {});
                              newIndController.clear();
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 350),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _industries.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ind = _industries[index];
                          return ListTile(
                            dense: true,
                            title: Text(ind, style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  _industries.removeAt(index);
                                  if (_selectedIndustry == ind) _selectedIndustry = null;
                                  _saveIndustries();
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
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManageEmployeeCountsDialog() {
    final newCountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Employee Counts', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            controller: newCountController,
                            decoration: const InputDecoration(
                              labelText: 'New Employee Count',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final val = newCountController.text.trim();
                            if (val.isNotEmpty && !_employeeCountOptions.contains(val)) {
                              setState(() {
                                _employeeCountOptions.add(val);
                                _saveEmployeeCounts();
                              });
                              setDialogState(() {});
                              newCountController.clear();
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 350),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _employeeCountOptions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ind = _employeeCountOptions[index];
                          return ListTile(
                            dense: true,
                            title: Text(ind, style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  _employeeCountOptions.removeAt(index);
                                  if (_employeeCount == ind) _employeeCount = null;
                                  _saveEmployeeCounts();
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
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {`;
    content = content.replace("  @override\n  Widget build(BuildContext context) {", dialogs);
    content = content.replace("  @override\r\n  Widget build(BuildContext context) {", dialogs);

    // 8. Replace Industry Field in build() - using Regex for flexible whitespace handling
    const industryRegex = /                            child: TextFormField\(\r?\n                              controller: _industryController,\r?\n                              decoration: const InputDecoration\(\r?\n                                labelText: 'Industry \*',\r?\n                                hintText: 'e\.g\. FinTech',\r?\n                                prefixIcon: Icon\(Icons\.category\),\r?\n                              \),\r?\n                              validator: \(v\) => v!\.trim\(\)\.isEmpty\r?\n                                  \? 'Industry is required'\r?\n                                  : null,\r?\n                            \),/;
    
    const industryNew = `                            child: DropdownButtonFormField<String>(
                              value: _selectedIndustry,
                              decoration: const InputDecoration(
                                labelText: 'Industry *',
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _industries
                                  .map((ind) => DropdownMenuItem(
                                        value: ind,
                                        child: Text(ind),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedIndustry = val;
                                });
                              },
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Industry is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            tooltip: 'Manage Industries',
                            onPressed: _showManageIndustriesDialog,
                          `;
    content = content.replace(industryRegex, industryNew);
    
    // 9. Replace Employee Count Field in build()
    const empRegex = /                              isExpanded: true,\r?\n                            \),\r?\n                          \),\r?\n                          const SizedBox\(width: 12\),\r?\n                          Expanded\(\r?\n                            child: TextFormField\(\r?\n                              controller: _branchCountController,/;
    const empNew = `                              isExpanded: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            tooltip: 'Manage Employee Counts',
                            onPressed: _showManageEmployeeCountsDialog,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _branchCountController,`;
    content = content.replace(empRegex, empNew);
    
    fs.writeFileSync(path, content);
}

fixAddCompany();
console.log("Done");
