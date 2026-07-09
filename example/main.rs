use std::env;

fn main() {
    print_hello();

    if env::args().len() > 1 {
        println!("args passed through exe:");
        for arg in env::args().skip(1) {
            println!("  {}", arg);
        }
    } else {
        println!("no args passed");
    }
}

fn print_hello() {
    println!("Hello Rust!");
}
