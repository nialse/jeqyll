#!/bin/sh
set -eu
cd "$(dirname "$0")"
output=${1:-build}
project_dir=$(pwd -P)
case "$output" in
    ""|/|.|..|/home|/Users|"$project_dir") echo 'Choose a dedicated output directory' >&2; exit 2 ;;
esac
mkdir -p "$output"
for source in src/*.ll; do
    name=$(basename "$source" .ll)
    llvm-as "$source" -o "$output/$name.bc"
    opt -passes=verify "$output/$name.bc" -o /dev/null
done
llvm-as libmuffintop/src/libmuffintop.ll -o "$output/libmuffintop.bc"
llvm-as libmuffintop/src/host/linux_x86_64.ll -o "$output/host.bc"
llvm-as libmuffintop/src/host/linux_common.ll -o "$output/host_common.bc"
llvm-as libmuffintop/src/start/linux_x86_64.ll -o "$output/start.bc"
set --
for source in src/*.ll; do
    name=$(basename "$source" .ll)
    set -- "$@" "$output/$name.bc"
done
llvm-link "$@" "$output/libmuffintop.bc" "$output/host.bc" "$output/host_common.bc" "$output/start.bc" -o "$output/linked.bc"
opt -passes='default<O1>,verify' "$output/linked.bc" -o "$output/jeqy.bc"
llc -filetype=obj -relocation-model=static "$output/jeqy.bc" -o "$output/jeqy.o"
ld -static -e _start "$output/jeqy.o" -o "$output/jeqy"
nm -u "$output/jeqy" > "$output/undefined-symbols.txt"
test ! -s "$output/undefined-symbols.txt"
readelf -h -l -d "$output/jeqy" > "$output/elf-inspection.txt"
sha256sum src/*.ll libmuffintop/src/libmuffintop.ll \
    libmuffintop/src/host/linux_x86_64.ll libmuffintop/src/host/linux_common.ll \
    libmuffintop/src/start/linux_x86_64.ll > "$output/source-sha256.txt"
sha256sum "$output/jeqy" > "$output/binary-sha256.txt"
if readelf -l "$output/jeqy" | rg -q INTERP; then
    echo 'Unexpected ELF interpreter' >&2
    exit 1
fi
if readelf -d "$output/jeqy" | rg -q NEEDED; then
    echo 'Unexpected dynamic dependency' >&2
    exit 1
fi
cp "$output/jeqy" jeqy.next
mv jeqy.next jeqy
printf 'Built %s/jeqy and ./jeqy\n' "$output"
