const path = require('path');

require('esbuild').build({
  entryPoints: ["esbuild.js", "application.js"],
    bundle: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    absWorkingDir: path.join(process.cwd(), "app/javascript"),
    plugins: [require('esbuild-svelte')()],
    watch: process.argv.includes("--watch"),
    logLevel: "info",
}).catch(() => process.exit(1));