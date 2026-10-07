const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');
const output = path.join(root, 'PortableKiosk', 'Content', 'tailwind.css');
const temporary = `${output}.${process.pid}.tmp`;
const packagePath = require.resolve('@tailwindcss/cli/package.json');
const metadata = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
const cli = path.resolve(path.dirname(packagePath), metadata.bin.tailwindcss);

try {
    const build = spawnSync(process.execPath, [
        cli, '-i', 'PortableKiosk/Content/tailwind.input.css',
        '-o', temporary, '--minify'
    ], { cwd: root, stdio: 'inherit', windowsHide: true });

    if (build.error) throw build.error;
    if (build.status !== 0) throw new Error(`Tailwind exited with status ${build.status}.`);

    const css = fs.readFileSync(temporary, 'utf8');
    // Source discovery can silently fail in a restricted Windows environment.
    // These utilities are used by customer, admin, POS, and kitchen pages.
    const required = ['.flex{', '.grid{', '.bg-white{', '.rounded-xl{', '.text-slate-900{'];
    const missing = required.filter(selector => !css.includes(selector));
    if (missing.length) {
        throw new Error(`Source scanning missed app utilities: ${missing.join(', ')}. Run the build in a terminal with read access to the project sources.`);
    }

    if (process.argv.includes('--check')) {
        console.log('CSS source scanning passed. The deployed stylesheet was left unchanged.');
    } else {
        fs.renameSync(temporary, output);
        console.log('CSS source scanning passed. Updated Content/tailwind.css.');
    }
} catch (error) {
    console.error(`CSS build failed; the existing stylesheet was preserved. ${error.message}`);
    process.exitCode = 1;
} finally {
    if (fs.existsSync(temporary)) fs.unlinkSync(temporary);
}
