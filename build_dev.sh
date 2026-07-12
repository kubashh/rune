# usage: sh build_dev.sh && ./dist/test/rune example/main.c dist/bin/main --run "space arg" arg2
# IMPORTANT: this script build DEBUG release, do not build release with it!!!
clear
echo "\033[33mwarning\033[0m: building \033[31mDEBUG\033[0m rune release! do not use it in production! Never publish it!!!\n"
rm ./dist -rf # remove prev exe to make shure that current running is latest
rune src/main.zig dist/test/rune --debug
