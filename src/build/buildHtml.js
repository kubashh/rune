const entry_path = process.argv[1];
const outpath = process.argv[2];
const minify = process.argv.includes(`--minify`);

const { outputs } = await Bun.build({
  entrypoints: [entry_path],
  outdir: `.`,
  naming: outpath,
  compile: true,
  minify,
});

if (minify) {
  // bun makes empty script tag and left comments, so it can be removed to reduce the size of the output file
  const witoutScriptsAndComments = removeScriptsAndComments(
    await Bun.file(outpath).text(),
  );
  // bun minify do not minify the html, so we need to minify it manually
  const minifiedHtml = minifyHtml(witoutScriptsAndComments);

  await Bun.write(outpath, minifiedHtml);
}

function removeScriptsAndComments(text) {
  return text
    .replaceAll(`<script></script>`, ``) // remove empty script
    .replaceAll(`<script type="module"></script>`, ``) // remove empty script
    .replaceAll(/<!--[\s\S]*?-->/g, ``);
}

// function minified html skipping <script> tag content
function minifyHtml(text) {
  const scripts = [];
  const token = (i) => `__SCRIPT_BLOCK_${i}__`;

  // extract all script blocks (handles attributes too)
  const withoutScripts = text.replace(
    /<script\b[^>]*>[\s\S]*?<\/script>/gi,
    (m) => {
      const i = scripts.length;
      scripts.push(m); // keep original
      return token(i);
    },
  );

  // minify html
  const minified = withoutScripts
    .replaceAll(/\/\*[\s\S]*?\*\//g, ``) // remove comments
    .replaceAll(`\n`, ` `)
    .replaceAll(/\s{2,}/g, ` `)
    .replaceAll(/ > | >|> /g, `>`)
    .replaceAll(/ < | <|< /g, `<`)
    .replaceAll(/ ; | ;|; /g, `;`)
    .replaceAll(/ { | {|{ /g, `{`)
    .replaceAll(/ } | }|} /g, `}`)
    .replaceAll(/ " | "|" /g, `"`)
    .replaceAll(/ , | ,|, /g, `,`)
    .replaceAll(`: `, `:`); // color: red; => color:red;

  // restore script blocks
  return minified
    .replace(/__SCRIPT_BLOCK_(\d+)__/g, (_, n) => scripts[n])
    .replace(/;\n<\/script|;<\/script|\n<\/script/, `</script`); // remove ';' if exists and '\n'
}
