# usage: sh build_dev.sh && ./dist/test/rune example/cli/main.c dist/bin/main --run "space arg" arg2
# IMPORTANT: this script build DEBUG release, do not build release with it!!!
clear
rm ./dist -rf # remove prev exe to make sure that current running is latest
rune src/main.zig dist/test/rune --debug
