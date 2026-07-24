# usage: sh build_dev.sh && ./dist/test/rune example/cli/main.c dist/bin/main --run some_arg
# IMPORTANT: this script build DEBUG release, do not build release with it!!!
clear
rm ./dist -rf # remove prev exe to make sure that current running is latest
bun build src/build/buildHtml.js --outfile src/build/buildHtmlMinified.js --target=node --minify # build js, later rune build
rune src/main.zig dist/test/rune --debug
rm ./src/build/buildHtmlMinified.js
