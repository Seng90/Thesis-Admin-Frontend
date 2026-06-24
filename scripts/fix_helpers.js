const fs = require('fs');
const path = require('path');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(function(file) {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) { 
            results = results.concat(walk(file));
        } else { 
            if (file.endsWith('_details_view.dart')) results.push(file);
        }
    });
    return results;
}

const oldInfo = `        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),`;
        
const newInfo = `        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),`;

const oldGlance = `        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),`;

const newGlance = `        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),`;

const files = walk(path.join(__dirname, '..', 'lib', 'features'));
for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    let newContent = content.replace(oldInfo, newInfo).replace(oldGlance, newGlance);
    
    // Some have `const Text(label` instead of `Text(label` if the variables were different, but it's exactly like this.
    // Let's do regex for more robustness.
    
    const infoRegex = /Column\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*Text\(label,\s*style:\s*const\s*TextStyle\(fontSize:\s*12,\s*color:\s*AppColors\.textMuted\)\),\s*Text\(value,\s*style:\s*const\s*TextStyle\(fontSize:\s*14,\s*fontWeight:\s*FontWeight\.w500\)\),\s*\],\s*\),/g;
    const newInfoStr = `Expanded(\n          child: Column(\n            crossAxisAlignment: CrossAxisAlignment.start,\n            children: [\n              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),\n              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),\n            ],\n          ),\n        ),`;
    newContent = newContent.replace(infoRegex, newInfoStr);
    
    const glanceRegex = /Column\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*Text\(label,\s*style:\s*const\s*TextStyle\(fontSize:\s*12,\s*color:\s*AppColors\.textMuted\)\),\s*const\s*SizedBox\(height:\s*2\),\s*Text\(value,\s*style:\s*const\s*TextStyle\(fontSize:\s*14,\s*fontWeight:\s*FontWeight\.w600\)\),\s*\],\s*\),/g;
    const newGlanceStr = `Expanded(\n          child: Column(\n            crossAxisAlignment: CrossAxisAlignment.start,\n            children: [\n              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),\n              const SizedBox(height: 2),\n              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),\n            ],\n          ),\n        ),`;
    newContent = newContent.replace(glanceRegex, newGlanceStr);
    
    if (newContent !== content) {
        fs.writeFileSync(file, newContent);
        console.log('Updated helpers in', file);
    }
}
