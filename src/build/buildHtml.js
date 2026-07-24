import path from "path";

const entry_path = process.argv[1];
const outpath = process.argv[2];
const minify = process.argv.includes(`--minify`);
const noBundle = process.argv.includes(`--no-bundle`);
const crossorigin = process.argv.includes(`--crossorigin`);

const { outputs } = await Bun.build(
  !noBundle
    ? {
        entrypoints: [entry_path],
        outdir: `.`,
        naming: outpath,
        compile: true,
        minify,
      }
    : {
        entrypoints: [entry_path],
        outdir: path.dirname(outpath),
        minify,
      },
);

if (minify || !crossorigin) {
  // bun makes empty script tag and left comments, so it can be removed to reduce the size of the output file
  let html = await Bun.file(outpath).text();
  if (minify) {
    html = removeScriptsAndComments(html);
  }
  // bun add crossorigin attribute
  if (!crossorigin) {
    html = removeCrossorgin(html);
  }
  // bun minify css and js but not html, so we need to minify it manually
  if (minify) {
    html = minifyHtml(html);
  }

  await Bun.write(outpath, html);
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
    .replaceAll(/ , | ,|, /g, `,`);
  // .replaceAll(`: `, `:`); // color: red; => color:red;

  // restore script blocks
  return minified
    .replace(/__SCRIPT_BLOCK_(\d+)__/g, (_, n) => scripts[n])
    .replace(/;\n<\/script|;<\/script|\n<\/script/, `</script`); // remove ';' if exists and '\n'
}

// it may brake scripts
// TODO make it works only in <tag art1 crossorigin />
function removeCrossorgin(text) {
  return text.replaceAll(/\scrossorigin|crossorigin/g, ``);
}
