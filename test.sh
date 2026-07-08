# run before commit! this script tests building all possible targets
clear
rm ./dist -rf
mkdir ./dist/bin -p

# build rune
zig build-exe src/main.zig -Doptimize=Debug --name rune -femit-bin=dist/bin/rune  --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/

# build with different optimalization flags
./dist/bin/rune example/main.zig dist/bin/app-linux-x64-zig-debug --target=linux-x86_64 --debug     # debug
./dist/bin/rune example/main.zig dist/bin/app-linux-x64-zig-safe --target=linux-x86_64 --safe       # safe
./dist/bin/rune example/main.zig dist/bin/app-linux-x64-zig-size --target=linux-x86_64 --size       # size
./dist/bin/rune example/main.zig dist/bin/app-linux-x64-zig-release --target=linux-x86_64 --release # release

# build Zig
./dist/bin/rune example/main.zig dist/bin/app-linux-x64-zig --target=linux-x86_64 --release         # Linux x64 (glibc-based)
./dist/bin/rune example/main.zig dist/bin/app-linux-x64-zig --target=linux-x86_64-musl --release    # Linux x64 (musl-based)
./dist/bin/rune example/main.zig dist/bin/app-linux-arm64-zig --target=linux-aarch64 --release      # Linux ARM64 (aarch64)
./dist/bin/rune example/main.zig dist/bin/app-macos-arm64-zig --target=macos-aarch64 --release      # macOS ARM64 (Apple Silicon)
./dist/bin/rune example/main.zig dist/bin/app-macos-x64-zig --target=macos-x86_64 --release         # macOS x64 (Intel)
./dist/bin/rune example/main.zig dist/bin/app-windows-x64-zig --target=windows-x86_64 --release     # Windows x64

# build C
./dist/bin/rune example/main.c dist/bin/app-linux-x64-c --target=linux-x86_64 --release         # Linux x64 (glibc-based)
./dist/bin/rune example/main.c dist/bin/app-linux-x64-c --target=linux-x86_64-musl --release    # Linux x64 (musl-based)
./dist/bin/rune example/main.c dist/bin/app-linux-arm64-c --target=linux-aarch64 --release      # Linux ARM64 (aarch64)
./dist/bin/rune example/main.c dist/bin/app-macos-arm64-c --target=macos-aarch64 --release      # macOS ARM64 (Apple Silicon)
./dist/bin/rune example/main.c dist/bin/app-macos-x64-c --target=macos-x86_64 --release         # macOS x64 (Intel)
./dist/bin/rune example/main.c dist/bin/app-windows-x64-c --target=windows-x86_64 --release     # Windows x64
