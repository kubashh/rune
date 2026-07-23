#include "stdint.h"

__attribute__((visibility("default")))
int32_t add(int32_t a, int32_t b) {
    return a + b;
}

__attribute__((visibility("default")))
void _start(void) {
    // optional entry-like function
}
