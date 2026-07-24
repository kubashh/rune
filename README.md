# rune

Build & run tool designed for simple and predictable development in any major programming lang.

## Cli design

### 1. Cli args

```txt
usage (rune version): rune [input_path] [output_path | flag] [flags]
flags:
  --debug | --safe | --fast | --size              Set optimization level (default: --debug, when output_path provided: --fast)
  --target=[os]-[arch]-[abi?]                     Set target OS (default: current OS)

supported targets:
    linux-x86_64, linux-x86_64-musl, linux-aarch64, linux-aarch64-musl    Linux
    macos-x86_64, macos-aarch64                                           Darwin
    windows-x86_64, windows-aarch64                                       Windows
    browser                                           Wasm | HTML | CSS | JS | TS

  --run                   Run compiled program. evry arg passed after --run will be pass into running exe
  --info                  Print build/run info (useful for debugging)
  -h, --help              Show this help message

example usage:
  rune src/main.zig --run="my arg"
  rune src/main.rs
  rune src/main.c dist/main --fast
  rune src/main.cpp dist/main --debug
  rune src/server.js
  rune src/main.ts dist/main.js --size
  rune ./styles.css dist/styles.css --size
  rune src/index.html dist/index.html --size

supported extentions:
  .zig, .rs (native), .c, .cpp, .html, .css, .js, .ts, .jsx (node_modules), .tsx (node_modules)
```

## Project structure

### src

- ./src/build - contains all building stuffs
- ./src/cli - parse command line for get config
- ./src/lib - cross-project consts and utilities
- ./src/run - run program

### Other

- ./.cache (git ignored) - zig and rune cache
- ./dist (git ignored) - build output used in testing and releases for rune-web

## Build code with rune

```sh
rm -rf dist
echo "building with different flags..."

# test runners
rune example/cli/main.zig
rune example/cli/main.zig --target=windows-x86_64 --run "one arg"

# build with different optimalization flags
rune example/cli/main.zig dist/opt/zig-native-debug --debug
rune example/cli/main.zig dist/opt/zig-native-safe  --safe
rune example/cli/main.zig dist/opt/zig-native-size  --size
rune example/cli/main.zig dist/opt/zig-native-fast  --fast

# build Zig
rune example/cli/main.zig dist/zig/app-linux-x86_64       --target=linux-x86_64
rune example/cli/main.zig dist/zig/app-linux-x86_64-musl  --target=linux-x86_64-musl
rune example/cli/main.zig dist/zig/app-linux-aarch64      --target=linux-aarch64
rune example/cli/main.zig dist/zig/app-linux-aarch64-musl --target=linux-aarch64-musl
rune example/cli/main.zig dist/zig/app-macos-aarch64      --target=macos-aarch64
rune example/cli/main.zig dist/zig/app-macos-x86_64       --target=macos-x86_64
rune example/cli/main.zig dist/zig/app-windows-x86_64     --target=windows-x86_64
rune example/cli/main.zig dist/zig/app-windows-aarch64    --target=windows-aarch64
rune example/browser/wasm.zig dist/zig/app-browser.wasm   --target=browser

# build Rust
rune example/cli/main.rs dist/rs/app-linux-x86_64       --target=linux-x86_64
rune example/cli/main.rs dist/rs/app-linux-x86_64-musl  --target=linux-x86_64-musl
# rune example/cli/main.rs dist/rs/app-linux-aarch64      --target=linux-aarch64
# rune example/cli/main.rs dist/rs/app-linux-aarch64-musl --target=linux-aarch64-musl
# rune example/cli/main.rs dist/rs/app-macos-aarch64      --target=macos-aarch64
# rune example/cli/main.rs dist/rs/app-macos-x86_64       --target=macos-x86_64
# rune example/cli/main.rs dist/rs/app-windows-x86_64     --target=windows-x86_64
# rune example/cli/main.rs dist/rs/app-windows-aarch64    --target=windows-aarch64
# rune example/browser/wasm.rs dist/rs/app-browser.wasm   --target=browser

# build C
rune example/cli/main.c dist/c/app-linux-x86_64       --target=linux-x86_64
rune example/cli/main.c dist/c/app-linux-x86_64-musl  --target=linux-x86_64-musl
rune example/cli/main.c dist/c/app-linux-aarch64      --target=linux-aarch64
rune example/cli/main.c dist/c/app-linux-aarch64-musl --target=linux-aarch64-musl
rune example/cli/main.c dist/c/app-macos-aarch64      --target=macos-aarch64
rune example/cli/main.c dist/c/app-macos-x86_64       --target=macos-x86_64
rune example/cli/main.c dist/c/app-windows-x86_64     --target=windows-x86_64
rune example/cli/main.c dist/c/app-windows-aarch64    --target=windows-aarch64
rune example/browser/wasm.c dist/c/app-browser.wasm   --target=browser

# build C++
rune example/cli/main.cpp dist/cpp/app-linux-x86_64       --target=linux-x86_64
rune example/cli/main.cpp dist/cpp/app-linux-x86_64-musl  --target=linux-x86_64-musl
rune example/cli/main.cpp dist/cpp/app-linux-aarch64      --target=linux-aarch64
rune example/cli/main.cpp dist/cpp/app-linux-aarch64-musl --target=linux-aarch64-musl
rune example/cli/main.cpp dist/cpp/app-macos-aarch64      --target=macos-aarch64
rune example/cli/main.cpp dist/cpp/app-macos-x86_64       --target=macos-x86_64
rune example/cli/main.cpp dist/cpp/app-windows-x86_64     --target=windows-x86_64
rune example/cli/main.cpp dist/cpp/app-windows-aarch64    --target=windows-aarch64
rune example/browser/wasm.cpp dist/cpp/app-browser.wasm   --target=browser

# build HTML/CSS/JS
rune example/browser/index.html dist/browser/index.html
rune example/browser/styles.css dist/browser/new-styles.css
rune example/browser/script.js dist/browser/new-script.js

# build JS/TS
rune example/cli/main.js dist/js/app-linux-x86_64       --target=linux-x86_64
rune example/cli/main.js dist/js/app-linux-x86_64-musl  --target=linux-x86_64-musl
rune example/cli/main.js dist/js/app-linux-aarch64      --target=linux-aarch64
rune example/cli/main.js dist/js/app-linux-aarch64-musl --target=linux-aarch64-musl
rune example/cli/main.ts dist/ts/app-macos-aarch64      --target=macos-aarch64
rune example/cli/main.ts dist/ts/app-macos-x86_64       --target=macos-x86_64
rune example/cli/main.ts dist/ts/app-windows-x86_64     --target=windows-x86_64
rune example/cli/main.ts dist/ts/app-windows-aarch64    --target=windows-aarch64

# build python
# rune example/cli/main.py dist/py/app-linux-x86_64       --target=linux-x86_64
# rune example/cli/main.py dist/py/app-linux-x86_64-musl  --target=linux-x86_64-musl
# rune example/cli/main.py dist/py/app-linux-aarch64      --target=linux-aarch64
# rune example/cli/main.py dist/py/app-linux-aarch64-musl --target=linux-aarch64-musl
# rune example/cli/main.py dist/py/app-macos-aarch64      --target=macos-aarch64
# rune example/cli/main.py dist/py/app-macos-x86_64       --target=macos-x86_64
# rune example/cli/main.py dist/py/app-windows-x86_64     --target=windows-x86_64
# rune example/cli/main.py dist/py/app-windows-aarch64    --target=windows-aarch64
```

## Suppoted

### Targets

| Os-Arch-Abi       | Zig | Rust                      | C   | C++ | C#  | Java | Browser(Html/Css/JS/TS) | JSX//TSX          | Py  |
| ----------------- | --- | ------------------------- | --- | --- | --- | ---- | ----------------------- | ----------------- | --- |
| linux-x86_64      | ✅  | ⚠️ (native)               | ✅  | ✅  | ❌  | ❌   | ✅                      | ✅ (node_modules) | ❌  |
| linux-x86_64-musl | ✅  | ⚠️ (native, linux-x86_64) | ✅  | ✅  | ❌  | ❌   | ✅                      | ✅ (node_modules) | ❌  |
| linux-aarch64     | ✅  | ❌                        | ✅  | ✅  | ❌  | ❌   | ✅                      | ✅ (node_modules) | ❌  |
| macos-x86_64      | ✅  | ⚠️ (native)               | ✅  | ✅  | ❌  | ❌   | ✅                      | ✅ (node_modules) | ❌  |
| macos-aarch64     | ✅  | ⚠️ (native)               | ✅  | ✅  | ❌  | ❌   | ✅                      | ✅ (node_modules) | ❌  |
| windows-x86_64    | ✅  | ⚠️ (native)               | ✅  | ✅  | ❌  | ❌   | ✅                      | ✅ (node_modules) | ❌  |
| browser (wasm)    | ✅  | ❌                        | ✅  | ✅  | ❌  | ❌   | ✅                      | ✅ (node_modules) | ❌  |

### Code runners (Testing exe's)

| target                   | linux-x86_64 | linux-x86_64-musl | macos-x86_64 | macos-aarch64 | windows-x86_64 |
| ------------------------ | ------------ | ----------------- | ------------ | ------------- | -------------- |
| linux-x86_64             | ✅           | ❌                | ❌           | ❌            | ❌             |
| linux-x86_64-musl        | ❌           | ✅                | ❌           | ❌            | ❌             |
| linux-aarch64            | ❌           | ❌                | ❌           | ❌            | ❌             |
| linux-aarch64-musl       | ❌           | ❌                | ❌           | ❌            | ❌             |
| macos-x86_64             | ❌           | ❌                | ✅           | ❌            | ❌             |
| macos-aarch64            | ❌           | ❌                | ❌           | ✅            | ❌             |
| windows-x86_64           | ✅ (wine)    | ✅ (wine)         | ✅ (wine)    | ✅ (wine)     | ✅             |
| windows-aarch64          | ❌ (wine)    | ❌ (wine)         | ❌ (wine)    | ❌ (wine)     | ❌             |
| browser (wasm)           | ❌           | ❌                | ❌           | ❌            | ❌             |
| browser (Html/Css/JS/TS) | ✅           | ✅                | ✅           | ✅            | ✅             |

## TODO

- add support for: Rust (full), C#, Java, Wasm, Python
- rune.json
  - Parse config
  - Run scripts
  - Dev mode
  - Build mode
- build target windows: create .pdb file only when opt == .debug
- add support for development on android
- add support for zig cInclude (-lc)
- add support for compiler custom flags
- make sth like ArgParser as wrapper for args parsing
- add --types flag for .ts
- fix windows-aarch64 wine error
- minify js better
- add targets: android-[min_version], ios
- rune fmt .|.zig|.sh|... (format code)
