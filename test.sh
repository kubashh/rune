# run this script before commit, it will tests building all possible targets
clear && rm ./dist -rf
mkdir ./dist/bin -p

# build rune
zig build-exe src/main.zig -Doptimize=Debug --name rune -femit-bin=dist/bin/rune  --cache-dir .cache/zig

# build with different optimalization flags
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-debug --debug
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-safe  --safe
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-size  --size
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-fast  --fast

# build Zig
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64      --target=linux-x86_64
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-musl --target=linux-x86_64-musl
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-arm64    --target=linux-aarch64
./dist/bin/rune example/main.zig dist/bin/app-zig-macos-arm64    --target=macos-aarch64
./dist/bin/rune example/main.zig dist/bin/app-zig-macos-x64      --target=macos-x86_64
./dist/bin/rune example/main.zig dist/bin/app-zig-windows-x64    --target=windows-x86_64

# build C
./dist/bin/rune example/main.c dist/bin/app-c-linux-x64      --target=linux-x86_64
./dist/bin/rune example/main.c dist/bin/app-c-linux-x64-musl --target=linux-x86_64-musl
./dist/bin/rune example/main.c dist/bin/app-c-linux-arm64    --target=linux-aarch64
./dist/bin/rune example/main.c dist/bin/app-c-macos-arm64    --target=macos-aarch64
./dist/bin/rune example/main.c dist/bin/app-c-macos-x64      --target=macos-x86_64
./dist/bin/rune example/main.c dist/bin/app-c-windows-x64    --target=windows-x86_64

# build C++
./dist/bin/rune example/main.cpp dist/bin/app-cpp-linux-x64      --target=linux-x86_64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-linux-x64-musl --target=linux-x86_64-musl
./dist/bin/rune example/main.cpp dist/bin/app-cpp-linux-arm64    --target=linux-aarch64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-macos-arm64    --target=macos-aarch64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-macos-x64      --target=macos-x86_64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-windows-x64    --target=windows-x86_64
