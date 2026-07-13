// @ts-nocheck
printHello();

if (process.argv.length > 2) {
  console.log("args passed through exe:");
  // Skip exe path
  for (let i: number = 2; i < process.argv.length; i++) {
    console.log(`  ${process.argv[i]}`);
  }
} else {
  console.log("no args passed\n");
}

function printHello() {
  console.log("Hello JS");
}
