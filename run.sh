clear
rm ./dist -rf
mkdir ./dist/bin -p

# Build & run
zig build-exe src/main.zig -ODebug -Doptimize=Debug --name rune -femit-bin=dist/bin/rune  --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/
./dist/bin/rune $@
