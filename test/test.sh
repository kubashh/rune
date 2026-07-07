# Cross-platform build script using Zig
# Targets:
#   - Linux x64
#   - Linux ARM64
#   - macOS ARM64 (Apple Silicon)
#   - macOS x64 (Intel)
#   - Windows x64


# Output directory
OUT_DIR="dist"
SRC="main.zig"

# Start
clear
mkdir -p "$OUT_DIR"
echo "Building $SRC..."

# Linux x64 (glibc-based)
echo "[2/5] Building Linux x64..."
zig build-exe "$SRC" -Dtarget=x86_64-linux-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-linux-x64-zig"

# Linux ARM64 (aarch64)
echo "[3/5] Building Linux ARM64..."
zig build-exe "$SRC" -Dtarget=aarch64-linux-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-linux-arm64-zig"

# macOS ARM64 (Apple Silicon)
echo "[5/5] Building macOS ARM64..."
zig build-exe "$SRC" -Dtarget=aarch64-macos -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-macos-arm64-zig"

# macOS x64 (Intel)
echo "[4/5] Building macOS x64..."
zig build-exe "$SRC" -Dtarget=x86_64-macos -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-macos-x64-zig"

# Windows x64
echo "[1/5] Building Windows x64..."
zig build-exe "$SRC" -Dtarget=x86_64-windows-gnu -Doptimize=ReleaseFast -femit-bin="$OUT_DIR/app-windows-x64-zig"

echo "Done. See '$OUT_DIR'"
