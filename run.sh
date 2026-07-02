# For version 0.16.0
export ZIG_LIB_DIR=/opt/zig-0.16.0/lib

clear

# Build & run
zig build --prefix ./dist
./dist/bin/rune $@
