const std = @import("std");

// Exported function so JavaScript can call it.
// WebAssembly "i32" maps naturally to JS number (within 32-bit range).
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

// Optional: export an entry-like function if you want it.
export fn _start() void {}
