clear
rm ./dist -rf
mkdir ./dist/bin -p

# Build & run
zig build-exe src/main.zig -Doptimize=Debug --name rune -femit-bin=dist/bin/rune  --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/

# Test C builds
./dist/bin/rune test/main.c dist/bin/main-linux-x64 --target=linux-x86_64
./dist/bin/rune test/main.c dist/bin/main-linux-x64-save --target=linux-x86_64 --safe
./dist/bin/rune test/main.c dist/bin/main-windows-x64-debug --target=windows-x86_64 --debug
./dist/bin/rune test/main.c dist/bin/main-windows-x64-size --target=windows-x86_64 --size
./dist/bin/rune test/main.c dist/bin/main-macos-aarch64 --target=macos-aarch64 --release
./dist/bin/rune test/main.c dist/bin/main-macos-x64-size --target=macos-x86_64 --size
