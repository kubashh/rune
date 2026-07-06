clear
rm ./dist -rf
mkdir ./dist/bin -p

# Build & run
zig build-exe src/main.zig -ODebug -Doptimize=Debug --name rune -femit-bin=dist/bin/rune  --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/
# zig build --prefix ./dist
./dist/bin/rune test/main.c dist/bin/main-linux --target=linux-x86_64 --size
./dist/bin/rune test/main.c dist/bin/main-linux-save --target=linux-x86_64 --safe
./dist/bin/rune test/main.c dist/bin/main-windows --target=windows-x86_64 --release
./dist/bin/rune test/main.c dist/bin/main-windows-size --target=windows-x86_64 --size
./dist/bin/rune test/main.c dist/bin/main-macos --target=macos-x86_64 --release
./dist/bin/rune test/main.c dist/bin/main-macos-size --target=macos-x86_64 --size
