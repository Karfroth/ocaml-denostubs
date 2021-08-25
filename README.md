# esy-ocaml-inverted-ctypes-stubs

Tested on Ubuntu 20.04(WSL 2).
This project requires
- esy(0.6.11)
- deno(1.13.x)

## Usage

```
chmod +x build.sh
./build.sh
```

## Branches
- master: Basic example. Create a shared object and call ocaml function from a c program.
- node: Create an object and link it to node native library(with NAPI)
- denostubs: Create a shared object + typescript file which can be used on Deno(1.13.x)