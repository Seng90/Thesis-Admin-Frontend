import os

def fix_details_view(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix LayoutBuilder
    old_layout = """                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Card(
                              elevation: 0,"""
                              
    new_layout = """                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 600;
                          final card1 = Card(
                              elevation: 0,"""
                              
    if old_layout in content:
        content = content.replace(old_layout, new_layout)
        
        # We need to replace the closing tags of card1, card2, and the row.
        # This is a bit tricky with simple replace. Let's do regex or a more precise script.
        pass

def fix_helpers(content):
    # Fix _buildInfoRow
    old_info = """        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),"""
    new_info = """        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),"""
        
    # Fix _buildGlanceItem
    old_glance = """        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),"""
    new_glance = """        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),"""
        
    content = content.replace(old_info, new_info)
    content = content.replace(old_glance, new_glance)
    return content

import glob

# Read all dart files
for root, dirs, files in os.walk(r'd:\Thesis Project InvesTrack\investrack_admin\lib\features'):
    for file in files:
        if file.endswith('_details_view.dart'):
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            new_content = fix_helpers(content)
            if new_content != content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated helpers in {file}")

