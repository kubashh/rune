#include "iostream"

void printHello();

int main(int argc, char **argv) {
    printHello();

    if(argc > 1) {
        std::cout << "args passed through exe:\n";
        for (int i = 1; i < argc; i++) { // Skip exe path
            std::cout << "  " << argv[i] << '\n';
        }
    } else {
        std::cout << "no args passed\n";
    }

    return 0; // technically unnecessary, compiler adds return 0; at the end
}

void printHello() {
    std::cout << "Hello C++!\n";
}
