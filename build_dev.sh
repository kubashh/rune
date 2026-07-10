# usage: sh build_dev.sh && ./dist/test/rune example/main.c dist/bin/main --run="my args"
# after 0.1.0 consider using rune for building
# IMPORTANT: this script build DEBUG release, do not build release with it!!!
clear
echo "\033[33mwarning\033[0m: building \033[31mDEBUG\033[0m rune release! do not use it in production! Never publish it!!!\n"
rm ./dist -rf # remove prev exe to make shure that current running is latest
mkdir ./dist/test -p # for zig build (zig don't create output directory so no output created)
zig build-exe src/main.zig -ODebug -Doptimize=Debug --name rune -femit-bin=dist/test/rune  --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/
