# rune

Build & run tool for organizing codebase

[Zig 0.16.0 Realase Notes](https://ziglang.org/download/0.16.0/release-notes.html)

## Cli design

### 1. Cli args

```txt
Usage: rune [input_path] [output_path | flag] [flags]
Flags:
  --debug | --safe | --release | --size           Set optimization level (default: --debug)
  --target=[os]-[arch]-[abi?]                     Set target OS (default: current OS)
    os: linux | windows | macos | freebsd
    arch: x86_64 | x86
    abi?: gnu | musl | msvc

  -h, --help                                      Show this help message

Example usage:
  rune src/main.c
  rune src/main.c dist/main --release

Supported extentions:
  .c
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
    "build-linux": "rune src/main.zig --target=linux-x64 --release",
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

## Supoted targets

| Os-Arch-Abi        | ASM | Zig | Rust | C   | C++ | C#  | Java | Html | Css | JS/JSX/TS/TSX |
| ------------------ | --- | --- | ---- | --- | --- | --- | ---- | ---- | --- | ------------- |
| linux-x86_64       | ❌  | ❌  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| linux-x86_64-musl  | ❌  | ❌  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| linux-x86          | ❌  | ❌  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| macos-x86_64       | ❌  | ❌  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| macos-aarch64      | ❌  | ❌  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| windows-x86_64     | ❌  | ❌  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| windows-x86_64-gnu | ❌  | ❌  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |

## TODO

- Cross compilation
- Support: Zig, Rust, C, C++, Html, JS/TS (Bun/Node/Deno), Python
- Scripts
- Dev mode
- Release mode
- Parse config (rune.json)
