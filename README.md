# esy-ocaml-inverted-ctypes-stubs

Tested on Ubuntu 20.04(WSL 2).
This project requires libffi6 (For ubuntu 20.04, http://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb)

## Usage

```
chmod +x build.sh
./build.sh
```

## Branches
- master: Basic example. Create a shared object and call ocaml function from a c program.
- node: Create an object and link it to node native library(with NAPI)