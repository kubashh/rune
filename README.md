# rune

Build tool for organizing codebase

## Cli design

### 1. Cli args

1st arg input

```sh
rune input.ext output.ext --dev
```

### 2. rune.json

```json
{
  "build": {
    "linux": {
      "x64": "./dist/bin/linux-x64",
      "arm64": "./dist/bin/linux-arm64",
      "x86": "./dist/bin/linux-arm"
    },
    "macos": {
      "arm64": "./dist/bin/macos-arm64",
      "x64": "./dist/bin/macos-x64"
    },
    "windows": {
      "x64": "./dist/bin/windows-x64",
      "arm64": "./dist/bin/windows-arm64",
      "x86": "./dist/bin/windows-arm"
    }
  },
  "scripts:": {
    "default": "rune src/main.zig",
    "build-linux": "rune src/main.zig --linux --x64 --arm64 --x86",
    "build-macos": "rune src/main.zig --macos --arm64 --x64",
    "build-windows": "rune src/main.zig --windows --x64 --arm64 --x86"
  }
}
```

## Build with zig

```sh
#!/usr/bin/env bash
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
mkdir -p "$OUT_DIR"
echo "Building $SRC and $SRC_ZIG with Zig cross-compilation..."
echo "Output directory: $OUT_DIR"
echo "----------------------------------------"

# Windows x64
echo "[1/5] Building Windows x64..."
zig cc "$SRC" -target x86_64-windows-gnu -O ReleaseFast -o "$OUT_DIR/app-windows-x64.exe"
zig build-exe "$SRC_ZIG" -target x86_64-windows-gnu -O ReleaseFast -femit-bin="$OUT_DIR/app-windows-x64.exe"

# Linux x64 (glibc-based)
echo "[2/5] Building Linux x64..."
zig cc "$SRC" -target x86_64-linux-gnu -O ReleaseFast -o "$OUT_DIR/app-linux-x64"
zig build-exe "$SRC_ZIG" -target x86_64-linux-gnu -O ReleaseFast -femit-bin="$OUT_DIR/app-linux-x64"

# Linux ARM64 (aarch64)
echo "[3/5] Building Linux ARM64..."
zig cc "$SRC" -target aarch64-linux-gnu -O ReleaseFast -o "$OUT_DIR/app-linux-arm64"
zig build-exe "$SRC_ZIG" -target aarch64-linux-gnu -O ReleaseFast -femit-bin="$OUT_DIR/app-linux-arm64"

# macOS x64 (Intel)
echo "[4/5] Building macOS x64..."
zig cc "$SRC" -target x86_64-macos -O ReleaseFast -o "$OUT_DIR/app-macos-x64"
zig build-exe "$SRC_ZIG" -target x86_64-macos -O ReleaseFast -femit-bin="$OUT_DIR/app-macos-x64"

# macOS ARM64 (Apple Silicon)
echo "[5/5] Building macOS ARM64..."
zig cc "$SRC" -target aarch64-macos -O ReleaseFast -o "$OUT_DIR/app-macos-arm64"
zig build-exe "$SRC_ZIG" -target aarch64-macos -O ReleaseFast -femit-bin="$OUT_DIR/app-macos-arm64"

echo "----------------------------------------"
echo "All builds completed successfully."
echo "Binaries are in: $OUT_DIR/"
```

## TODO

- Cross compilation
- Support: Zig, Rust, C, C++, Html, JS/TS (Bun/Node/Deno), Python
- Scripts
- Dev mode
- Release mode
- Parse config (rune.json)
