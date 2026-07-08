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
# Cross-platform build script using rune for building Zig, C
# Targets:
#   - Linux x64
#   - Linux ARM64
#   - macOS ARM64 (Apple Silicon)
#   - macOS x64 (Intel)
#   - Windows x64

rm -rf dist
echo "building with different flags..."

rune example/main.zig dist/bin/app-linux-x64-zig-debug --target=linux-x86_64 --debug     # debug
rune example/main.zig dist/bin/app-linux-x64-zig-safe --target=linux-x86_64 --safe       # safe
rune example/main.zig dist/bin/app-linux-x64-zig-size --target=linux-x86_64 --size       # size
rune example/main.zig dist/bin/app-linux-x64-zig-release --target=linux-x86_64 --release # release

echo "building Zig..."

rune example/main.zig dist/bin/app-linux-x64-zig --target=linux-x86_64 --release     # Linux x64 (glibc-based)
rune example/main.zig dist/bin/app-linux-arm64-zig --target=linux-aarch64 --release  # Linux ARM64 (aarch64)
rune example/main.zig dist/bin/app-macos-arm64-zig --target=macos-aarch64 --release  # macOS ARM64 (Apple Silicon)
rune example/main.zig dist/bin/app-macos-x64-zig --target=macos-x86_64 --release     # macOS x64 (Intel)
rune example/main.zig dist/bin/app-windows-x64-zig --target=windows-x86_64 --release # Windows x64

echo "building C..."

rune example/main.c dist/bin/app-linux-x64-c --target=linux-x86_64 --release     # Linux x64 (glibc-based)
rune example/main.c dist/bin/app-linux-arm64-c --target=linux-aarch64 --release  # Linux ARM64 (aarch64)
rune example/main.c dist/bin/app-macos-arm64-c --target=macos-aarch64 --release  # macOS ARM64 (Apple Silicon)
rune example/main.c dist/bin/app-macos-x64-c --target=macos-x86_64 --release     # macOS x64 (Intel)
rune example/main.c dist/bin/app-windows-x64-c --target=windows-x86_64 --release # Windows x64

echo "done."
```

## Supoted targets

| Os-Arch-Abi        | ASM | Zig | Rust | C   | C++ | C#  | Java | Html | Css | JS/JSX/TS/TSX |
| ------------------ | --- | --- | ---- | --- | --- | --- | ---- | ---- | --- | ------------- |
| linux-x86_64       | ❌  | ✅  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| linux-x86_64-musl  | ❌  | ✅  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| linux-aarch64      | ❌  | ✅  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| macos-x86_64       | ❌  | ✅  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| macos-aarch64      | ❌  | ✅  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| windows-x86_64     | ❌  | ✅  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |
| windows-x86_64-gnu | ❌  | ✅  | ❌   | ✅  | ❌  | ❌  | ❌   | ❌   | ❌  | ❌            |

## TODO

- Cross compilation
- Support: Zig, Rust, C, C++, Html, JS/TS (Bun/Node/Deno), Python
- Scripts
- Dev mode
- Release mode
- Parse config (rune.json)
