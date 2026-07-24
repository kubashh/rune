VERSION="0.2.0"
rm ./dist -rf # remove prev exe to make sure that current running is latest
sh build_dev.sh
bun build src/build/buildHtml.js --outfile src/build/buildHtmlMinified.js --target=node --minify # build js, later rune build

rune src/main.zig dist/$VERSION/rune-$VERSION-linux-x86_64       --target=linux-x86_64
rune src/main.zig dist/$VERSION/rune-$VERSION-linux-x86_64-musl  --target=linux-x86_64-musl
# rune src/main.zig dist/$VERSION/rune-$VERSION-linux-aarch64      --target=linux-aarch64
# rune src/main.zig dist/$VERSION/rune-$VERSION-linux-aarch64-musl --target=linux-aarch64-musl
rune src/main.zig dist/$VERSION/rune-$VERSION-macos-aarch64      --target=macos-aarch64
rune src/main.zig dist/$VERSION/rune-$VERSION-macos-x86_64       --target=macos-x86_64
rune src/main.zig dist/$VERSION/rune-$VERSION-windows-x86_64     --target=windows-x86_64
# rune src/main.zig dist/$VERSION/rune-$VERSION-windows-aarch64    --target=windows-aarch64
rm ./src/build/buildHtmlMinified.js
