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
            if (file.endsWith('.dart')) results.push(file);
        }
    });
    return results;
}

const files = walk(path.join(__dirname, '..', 'lib', 'features'));
for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    if (content.includes('padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)')) {
        const newContent = content.replace(/padding: const EdgeInsets\.symmetric\(horizontal: 32\.0, vertical: 16\.0\)/g, 'padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0)');
        fs.writeFileSync(file, newContent);
        console.log('Updated', file);
    }
}
