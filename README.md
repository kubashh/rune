# rune

Build & run tool for organizing codebase

## Cli design

### 1. Cli args

```txt
usage: rune [input_path] [output_path | flag] [flags]
flags:
  --debug | --safe | --fast | --size              Set optimization level (default: --debug, when output_path provided: --fast)
  --target=[os]-[arch]-[abi?]                     Set target OS (default: current OS)

supported targets:
    linux-x86_64, linux-x86_64-musl, linux-aarch64    Linux
    macos-x86_64, macos-aarch64                       Darwin
    windows-x86_64, windows-x86_64-gnu                Windows
    browser                                           Wasm | HTML | JS | TS

  --run                                           Run compiled program. Use only when output_path is provided
  -h, --help                                      Show this help message

example usage:
  rune src/main.zig
  rune src/main.c dist/main --fast

supported extentions:
  .zig, .c, .cpp
```

<!-- ### 2. rune.json

```json
{
  "scripts:": {
    "default": "rune src/main.zig",
    "build-linux": "rune src/main.zig --target=linux-x64 --fast",
    "build-macos": "rune src/main.zig --macos --arm64 --x64",
    "build-windows": "rune src/main.zig --windows --x64 --arm64 --x86"
  }
}
``` -->

## Build code with rune

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

# build with different optimalization flags
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-debug --debug
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-safe  --safe
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-size  --size
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-fast  --fast

# build Zig
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64      --target=linux-x86_64
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-x64-musl --target=linux-x86_64-musl
./dist/bin/rune example/main.zig dist/bin/app-zig-linux-arm64    --target=linux-aarch64
./dist/bin/rune example/main.zig dist/bin/app-zig-macos-arm64    --target=macos-aarch64
./dist/bin/rune example/main.zig dist/bin/app-zig-macos-x64      --target=macos-x86_64
./dist/bin/rune example/main.zig dist/bin/app-zig-windows-x64    --target=windows-x86_64
./dist/bin/rune example/wasm.zig dist/bin/app-zig-browser.wasm   --target=browser

# build Rust
./dist/bin/rune example/main.rs dist/bin/app-rs-linux-x64      --target=linux-x86_64
./dist/bin/rune example/main.rs dist/bin/app-rs-linux-x64-musl --target=linux-x86_64-musl
# ./dist/bin/rune example/main.rs dist/bin/app-rs-linux-arm64    --target=linux-aarch64
# ./dist/bin/rune example/main.rs dist/bin/app-rs-macos-arm64    --target=macos-aarch64
# ./dist/bin/rune example/main.rs dist/bin/app-rs-macos-x64      --target=macos-x86_64
# ./dist/bin/rune example/main.rs dist/bin/app-rs-windows-x64    --target=windows-x86_64

# build C
./dist/bin/rune example/main.c dist/bin/app-c-linux-x64      --target=linux-x86_64
./dist/bin/rune example/main.c dist/bin/app-c-linux-x64-musl --target=linux-x86_64-musl
./dist/bin/rune example/main.c dist/bin/app-c-linux-arm64    --target=linux-aarch64
./dist/bin/rune example/main.c dist/bin/app-c-macos-arm64    --target=macos-aarch64
./dist/bin/rune example/main.c dist/bin/app-c-macos-x64      --target=macos-x86_64
./dist/bin/rune example/main.c dist/bin/app-c-windows-x64    --target=windows-x86_64
./dist/bin/rune example/wasm.c dist/bin/app-c-browser.wasm   --target=browser

# build C++
./dist/bin/rune example/main.cpp dist/bin/app-cpp-linux-x64      --target=linux-x86_64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-linux-x64-musl --target=linux-x86_64-musl
./dist/bin/rune example/main.cpp dist/bin/app-cpp-linux-arm64    --target=linux-aarch64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-macos-arm64    --target=macos-aarch64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-macos-x64      --target=macos-x86_64
./dist/bin/rune example/main.cpp dist/bin/app-cpp-windows-x64    --target=windows-x86_64
./dist/bin/rune example/wasm.cpp dist/bin/app-cpp-browser.wasm   --target=browser
```

## Suppoted

### Targets

| Os-Arch-Abi        | Zig | Rust        | C   | C++ | C#  | Java | Html | Css | JS/JSX/TS/TSX | Py  |
| ------------------ | --- | ----------- | --- | --- | --- | ---- | ---- | --- | ------------- | --- |
| linux-x86_64       | ✅  | ⚠️ (native) | ✅  | ✅  | ❌  | ❌   | ❌   | ❌  | ❌            | ❌  |
| linux-x86_64-musl  | ✅  | ⚠️ (native) | ✅  | ✅  | ❌  | ❌   | ❌   | ❌  | ❌            | ❌  |
| linux-aarch64      | ✅  | ⚠️ (native) | ✅  | ✅  | ❌  | ❌   | ❌   | ❌  | ❌            | ❌  |
| macos-x86_64       | ✅  | ⚠️ (native) | ✅  | ✅  | ❌  | ❌   | ❌   | ❌  | ❌            | ❌  |
| macos-aarch64      | ✅  | ⚠️ (native) | ✅  | ✅  | ❌  | ❌   | ❌   | ❌  | ❌            | ❌  |
| windows-x86_64     | ✅  | ⚠️ (native) | ✅  | ✅  | ❌  | ❌   | ❌   | ❌  | ❌            | ❌  |
| windows-x86_64-gnu | ✅  | ⚠️ (native) | ✅  | ✅  | ❌  | ❌   | ❌   | ❌  | ❌            | ❌  |

### Code runners (Testing exe's)

| target             | linux-x86_64 | linux-x86_64-musl | macos-x86_64  | macos-aarch64 | windows-x86_64 | windows-x86_64-gnu |
| ------------------ | ------------ | ----------------- | ------------- | ------------- | -------------- | ------------------ |
| linux-x86_64       | ✅           | ❌                | ❌            | ❌            | ❌             | ❌                 |
| linux-x86_64-musl  | ❌           | ✅                | ❌            | ❌            | ❌             | ❌                 |
| linux-aarch64      | ❌           | ❌                | ✅            | ❌            | ❌             | ❌                 |
| macos-x86_64       | ❌           | ❌                | ❌            | ❌            | ❌             | ❌                 |
| macos-aarch64      | ❌           | ❌                | ❌            | ✅            | ❌             | ❌                 |
| windows-x86_64     | ✅ (wine)    | ⚠️ (wine - ?)     | ⚠️ (wine - ?) | ⚠️ (wine - ?) | ✅             | ❌                 |
| windows-x86_64-gnu | ❌           | ❌                | ❌            | ❌            | ❌             | ✅                 |

## TODO

- add support for: Rust (full), C#, Java, Html, Css, JS/JSX/TS/TSX, Python
- rune.json
  - Parse config
  - Run scripts
  - Dev mode
  - Release mode
- build target windows: create .pdb file only when opt == .debug
- fix runProgram with "" (empty string)
