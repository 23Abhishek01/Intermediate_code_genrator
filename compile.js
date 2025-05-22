const fs = require('fs');
const { spawn } = require('child_process');
const path = require('path');

// Get the source file from command line arguments
const sourceFile = process.argv[2];

if (!sourceFile) {
    console.error('Please provide a source file path');
    console.log('Usage: node compile.js <source-file>');
    process.exit(1);
}

// Read the source file
try {
    const sourceCode = fs.readFileSync(sourceFile, 'utf8');
    
    // Run the compiler
    const compiler = spawn('compiler.exe', [], {
        cwd: __dirname
    });

    let output = '';
    let error = '';

    // Pipe the source code to the compiler
    compiler.stdin.write(sourceCode);
    compiler.stdin.end();

    // Collect output
    compiler.stdout.on('data', (data) => {
        output += data.toString();
    });

    compiler.stderr.on('data', (data) => {
        error += data.toString();
    });

    compiler.on('close', (code) => {
        if (code !== 0) {
            console.error('Compilation error:', error);
            process.exit(1);
        }
        console.log('Compilation successful:', output);
    });
} catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
} 