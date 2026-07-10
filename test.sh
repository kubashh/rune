# run this script before commit, it will tests building all possible targets
sh ./build_dev.sh

# test runners
./dist/test/rune example/main.zig dist/bin/runner-native --run="my args"
./dist/test/rune example/main.zig dist/bin/runner-wine-windows-x64 --target=windows-x86_64 --run="my args"

# build with different optimalization flags
./dist/test/rune example/main.zig dist/bin/app-zig-linux-x64-debug --debug
./dist/test/rune example/main.zig dist/bin/app-zig-linux-x64-safe  --safe
./dist/test/rune example/main.zig dist/bin/app-zig-linux-x64-size  --size
./dist/test/rune example/main.zig dist/bin/app-zig-linux-x64-fast  --fast

# build Zig
./dist/test/rune example/main.zig dist/bin/app-zig-linux-x64      --target=linux-x86_64
./dist/test/rune example/main.zig dist/bin/app-zig-linux-x64-musl --target=linux-x86_64-musl
./dist/test/rune example/main.zig dist/bin/app-zig-linux-arm64    --target=linux-aarch64
./dist/test/rune example/main.zig dist/bin/app-zig-macos-arm64    --target=macos-aarch64
./dist/test/rune example/main.zig dist/bin/app-zig-macos-x64      --target=macos-x86_64
./dist/test/rune example/main.zig dist/bin/app-zig-windows-x64    --target=windows-x86_64
./dist/test/rune example/wasm.zig dist/bin/app-zig-browser.wasm   --target=browser

# build Rust
./dist/test/rune example/main.rs dist/bin/app-rs-linux-x64      --target=linux-x86_64
./dist/test/rune example/main.rs dist/bin/app-rs-linux-x64-musl --target=linux-x86_64-musl
# ./dist/test/rune example/main.rs dist/bin/app-rs-linux-arm64    --target=linux-aarch64
# ./dist/test/rune example/main.rs dist/bin/app-rs-macos-arm64    --target=macos-aarch64
# ./dist/test/rune example/main.rs dist/bin/app-rs-macos-x64      --target=macos-x86_64
# ./dist/test/rune example/main.rs dist/bin/app-rs-windows-x64    --target=windows-x86_64

# build C
./dist/test/rune example/main.c dist/bin/app-c-linux-x64      --target=linux-x86_64
./dist/test/rune example/main.c dist/bin/app-c-linux-x64-musl --target=linux-x86_64-musl
./dist/test/rune example/main.c dist/bin/app-c-linux-arm64    --target=linux-aarch64
./dist/test/rune example/main.c dist/bin/app-c-macos-arm64    --target=macos-aarch64
./dist/test/rune example/main.c dist/bin/app-c-macos-x64      --target=macos-x86_64
./dist/test/rune example/main.c dist/bin/app-c-windows-x64    --target=windows-x86_64
./dist/test/rune example/wasm.c dist/bin/app-c-browser.wasm   --target=browser

# build C++
./dist/test/rune example/main.cpp dist/bin/app-cpp-linux-x64      --target=linux-x86_64
./dist/test/rune example/main.cpp dist/bin/app-cpp-linux-x64-musl --target=linux-x86_64-musl
./dist/test/rune example/main.cpp dist/bin/app-cpp-linux-arm64    --target=linux-aarch64
./dist/test/rune example/main.cpp dist/bin/app-cpp-macos-arm64    --target=macos-aarch64
./dist/test/rune example/main.cpp dist/bin/app-cpp-macos-x64      --target=macos-x86_64
./dist/test/rune example/main.cpp dist/bin/app-cpp-windows-x64    --target=windows-x86_64
./dist/test/rune example/wasm.cpp dist/bin/app-cpp-browser.wasm   --target=browser
