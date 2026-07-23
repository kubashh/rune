# run this script before commit, it will tests building all possible targets
sh ./build_dev.sh

# test runners
./dist/test/rune example/cli/main.zig
./dist/test/rune example/cli/main.zig --target=windows-x86_64 --run "one arg"

# build with different optimalization flags
./dist/test/rune example/cli/main.zig dist/opt/zig-native-debug --debug
./dist/test/rune example/cli/main.zig dist/opt/zig-native-safe  --safe
./dist/test/rune example/cli/main.zig dist/opt/zig-native-size  --size
./dist/test/rune example/cli/main.zig dist/opt/zig-native-fast  --fast

# build Zig
./dist/test/rune example/cli/main.zig dist/zig/app-linux-x86_64       --target=linux-x86_64
./dist/test/rune example/cli/main.zig dist/zig/app-linux-x86_64-musl  --target=linux-x86_64-musl
./dist/test/rune example/cli/main.zig dist/zig/app-linux-aarch64      --target=linux-aarch64
./dist/test/rune example/cli/main.zig dist/zig/app-linux-aarch64-musl --target=linux-aarch64-musl
./dist/test/rune example/cli/main.zig dist/zig/app-macos-aarch64      --target=macos-aarch64
./dist/test/rune example/cli/main.zig dist/zig/app-macos-x86_64       --target=macos-x86_64
./dist/test/rune example/cli/main.zig dist/zig/app-windows-x86_64     --target=windows-x86_64
./dist/test/rune example/cli/main.zig dist/zig/app-windows-aarch64    --target=windows-aarch64
./dist/test/rune example/browser/wasm.zig dist/zig/app-browser.wasm   --target=browser

# build Rust
./dist/test/rune example/cli/main.rs dist/rs/app-linux-x86_64       --target=linux-x86_64
./dist/test/rune example/cli/main.rs dist/rs/app-linux-x86_64-musl  --target=linux-x86_64-musl
# ./dist/test/rune example/cli/main.rs dist/rs/app-linux-aarch64      --target=linux-aarch64
# ./dist/test/rune example/cli/main.rs dist/rs/app-linux-aarch64-musl --target=linux-aarch64-musl
# ./dist/test/rune example/cli/main.rs dist/rs/app-macos-aarch64      --target=macos-aarch64
# ./dist/test/rune example/cli/main.rs dist/rs/app-macos-x86_64       --target=macos-x86_64
# ./dist/test/rune example/cli/main.rs dist/rs/app-windows-x86_64     --target=windows-x86_64
# ./dist/test/rune example/cli/main.rs dist/rs/app-windows-aarch64    --target=windows-aarch64
# ./dist/test/rune example/browser/wasm.rs dist/rs/app-browser.wasm   --target=browser

# build C
./dist/test/rune example/cli/main.c dist/c/app-linux-x86_64       --target=linux-x86_64
./dist/test/rune example/cli/main.c dist/c/app-linux-x86_64-musl  --target=linux-x86_64-musl
./dist/test/rune example/cli/main.c dist/c/app-linux-aarch64      --target=linux-aarch64
./dist/test/rune example/cli/main.c dist/c/app-linux-aarch64-musl --target=linux-aarch64-musl
./dist/test/rune example/cli/main.c dist/c/app-macos-aarch64      --target=macos-aarch64
./dist/test/rune example/cli/main.c dist/c/app-macos-x86_64       --target=macos-x86_64
./dist/test/rune example/cli/main.c dist/c/app-windows-x86_64     --target=windows-x86_64
./dist/test/rune example/cli/main.c dist/c/app-windows-aarch64    --target=windows-aarch64
./dist/test/rune example/browser/wasm.c dist/c/app-browser.wasm   --target=browser

# build C++
./dist/test/rune example/cli/main.cpp dist/cpp/app-linux-x86_64       --target=linux-x86_64
./dist/test/rune example/cli/main.cpp dist/cpp/app-linux-x86_64-musl  --target=linux-x86_64-musl
./dist/test/rune example/cli/main.cpp dist/cpp/app-linux-aarch64      --target=linux-aarch64
./dist/test/rune example/cli/main.cpp dist/cpp/app-linux-aarch64-musl --target=linux-aarch64-musl
./dist/test/rune example/cli/main.cpp dist/cpp/app-macos-aarch64      --target=macos-aarch64
./dist/test/rune example/cli/main.cpp dist/cpp/app-macos-x86_64       --target=macos-x86_64
./dist/test/rune example/cli/main.cpp dist/cpp/app-windows-x86_64     --target=windows-x86_64
./dist/test/rune example/cli/main.cpp dist/cpp/app-windows-aarch64    --target=windows-aarch64
./dist/test/rune example/browser/wasm.cpp dist/cpp/app-browser.wasm   --target=browser

# build HTML/CSS/JS
./dist/test/rune example/browser/index.html dist/browser/index.html
./dist/test/rune example/browser/styles.css dist/browser/new-styles.css
./dist/test/rune example/browser/script.js dist/browser/new-script.js

# build JS/TS
./dist/test/rune example/cli/main.js dist/js/app-linux-x86_64       --target=linux-x86_64
./dist/test/rune example/cli/main.js dist/js/app-linux-x86_64-musl  --target=linux-x86_64-musl
./dist/test/rune example/cli/main.js dist/js/app-linux-aarch64      --target=linux-aarch64
./dist/test/rune example/cli/main.js dist/js/app-linux-aarch64-musl --target=linux-aarch64-musl
./dist/test/rune example/cli/main.ts dist/ts/app-macos-aarch64      --target=macos-aarch64
./dist/test/rune example/cli/main.ts dist/ts/app-macos-x86_64       --target=macos-x86_64
./dist/test/rune example/cli/main.ts dist/ts/app-windows-x86_64     --target=windows-x86_64
./dist/test/rune example/cli/main.ts dist/ts/app-windows-aarch64    --target=windows-aarch64

# build python
# ./dist/test/rune example/cli/main.py dist/py/app-linux-x86_64       --target=linux-x86_64
# ./dist/test/rune example/cli/main.py dist/py/app-linux-x86_64-musl  --target=linux-x86_64-musl
# ./dist/test/rune example/cli/main.py dist/py/app-linux-aarch64      --target=linux-aarch64
# ./dist/test/rune example/cli/main.py dist/py/app-linux-aarch64-musl --target=linux-aarch64-musl
# ./dist/test/rune example/cli/main.py dist/py/app-macos-aarch64      --target=macos-aarch64
# ./dist/test/rune example/cli/main.py dist/py/app-macos-x86_64       --target=macos-x86_64
# ./dist/test/rune example/cli/main.py dist/py/app-windows-x86_64     --target=windows-x86_64
# ./dist/test/rune example/cli/main.py dist/py/app-windows-aarch64    --target=windows-aarch64
