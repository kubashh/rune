#include "stdio.h"

void printHello();

int main(int argc, char **argv) {
    printHello();

    if(argc > 1) {
        printf("args passed through exe:\n");
        for (int i = 1; i < argc; i++) { // Skip exe path
            printf("  %s\n", argv[i]);
        }
    } else {
        printf("no args passed\n");
    }

    return 0;
}

void printHello() {
    printf("Hello C!\n");
}
