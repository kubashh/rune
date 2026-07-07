# Cross-platform build script using Zig
# Targets:
#   - Linux x64
#   - Linux ARM64
#   - macOS ARM64 (Apple Silicon)
#   - macOS x64 (Intel)
#   - Windows x64

OUT_DIR="dist"
SRC="main.zig"

# Start
clear
mkdir -p "$OUT_DIR"
echo "Building $SRC..."

# Linux x64 (glibc-based)
zig build-exe "$SRC" -Dtarget=x86_64-linux-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-linux-x64-zig"

# Linux ARM64 (aarch64)
zig build-exe "$SRC" -Dtarget=aarch64-linux-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-linux-arm64-zig"

# macOS ARM64 (Apple Silicon)
zig build-exe "$SRC" -Dtarget=aarch64-macos -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-macos-arm64-zig"

# macOS x64 (Intel)
zig build-exe "$SRC" -Dtarget=x86_64-macos -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-macos-x64-zig"

# Windows x64
zig build-exe "$SRC" -Dtarget=x86_64-windows-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-windows-x64-zig"

echo "Done. See '$OUT_DIR'"
