# set -euo pipefail

# Cross-platform build script using Zig
# Targets:
#   - Windows x64
#   - Linux x64
#   - Linux ARM64
#   - macOS x64 (Intel)
#   - macOS ARM64 (Apple Silicon)


# Output directory
OUT_DIR="dist"
# Source file
SRC="main.c"
SRC_ZIG="main.zig"

# Start
clear
mkdir -p "$OUT_DIR"
echo "Building $SRC and $SRC_ZIG..."

# Windows x64
echo "[1/5] Building Windows x64..."
zig cc "$SRC" -Dtarget=x86_64-windows-gnu -Doptimize=ReleaseFast -o "$OUT_DIR/app-windows-x64"
zig build-exe "$SRC_ZIG" -Dtarget=x86_64-windows-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-windows-x64-zig"

# Linux x64 (glibc-based)
echo "[2/5] Building Linux x64..."
zig cc "$SRC" -Dtarget=x86_64-linux-gnu -Doptimize=ReleaseFast -o "$OUT_DIR/app-linux-x64"
zig build-exe "$SRC_ZIG" -Dtarget=x86_64-linux-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-linux-x64-zig"

# Linux ARM64 (aarch64)
echo "[3/5] Building Linux ARM64..."
zig cc "$SRC" -Dtarget=aarch64-linux-gnu -Doptimize=ReleaseFast -o "$OUT_DIR/app-linux-arm64"
zig build-exe "$SRC_ZIG" -Dtarget=aarch64-linux-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-linux-arm64-zig"

# macOS x64 (Intel)
echo "[4/5] Building macOS x64..."
zig cc "$SRC" -Dtarget=x86_64-macos -Doptimize=ReleaseFast -o "$OUT_DIR/app-macos-x64"
zig build-exe "$SRC_ZIG" -Dtarget=x86_64-macos -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-macos-x64-zig"

# macOS ARM64 (Apple Silicon)
echo "[5/5] Building macOS ARM64..."
zig cc "$SRC" -Dtarget=aarch64-macos -Doptimize=ReleaseFast -o "$OUT_DIR/app-macos-arm64"
zig build-exe "$SRC_ZIG" -Dtarget=aarch64-macos -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-macos-arm64-zig"

echo "Done."
echo "Binaries are in: $OUT_DIR/"
