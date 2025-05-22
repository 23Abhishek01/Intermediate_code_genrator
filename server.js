const express = require('express');
const bodyParser = require('body-parser');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

app.use(express.static(__dirname));
app.use(bodyParser.text());

app.post('/compile', (req, res) => {
    const sourceCode = req.body;
    const tempFile = path.join(__dirname, 'temp.c');

    fs.writeFileSync(tempFile, sourceCode);

    const compiler = spawn('compiler.exe', [], {
        cwd: __dirname
    });

    let output = '';
    let error = '';

    compiler.stdin.write(sourceCode);
    compiler.stdin.end();

    compiler.stdout.on('data', (data) => {
        output += data.toString();
    });

    compiler.stderr.on('data', (data) => {
        error += data.toString();
    });

    compiler.on('close', (code) => {
        fs.unlinkSync(tempFile);
        if (code !== 0) {
            res.status(500).send(error);
        } else {
            res.send(output);
        }
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});