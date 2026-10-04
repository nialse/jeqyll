# jeqyll

An independent jq-compatible executable written in human-readable LLVM IR.
The executable uses the libmuffintop submodule and has no libc or other
runtime-library dependency.

## Build

The Linux x86-64 build requires `llvm-as`, `llvm-link`, `opt`, `llc`, `ld`,
`nm`, `readelf`, `sha256sum`, and `rg`.

```sh
git submodule update --init
./build.sh
```

This produces the static executable `jeqy` and an inspected build tree in
`build/`.

Implementation provenance and third-party data notices are recorded in
`SOURCES.md`, `NOTICE.md`, and `licenses/`.
