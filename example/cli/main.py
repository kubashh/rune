import sys

def printHello():
    print("Hello Python")

printHello()

if len(sys.argv) > 2:
    print("args passed through exe:")
    # Skip exe path
    for i in range(2, len(sys.argv)):
        print(f"  {sys.argv[i]}")
else:
    print("no args passed\n")
