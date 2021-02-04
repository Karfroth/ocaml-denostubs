#! /bin/sh
esy install
esy dune build gen
esy dune exec gen/Gen.exe ./mylib
esy build
gcc -I _esy/default/build/install/default/lib/mylib -L _esy/default/build/install/default/lib/mylib client/asdf.c -Wl,--no-as-needed -ldl -lm -lmylib
LD_LIBRARY_PATH=_esy/default/build/install/default/lib/mylib ./a.out