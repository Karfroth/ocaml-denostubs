#! /bin/sh
rm -rf example
mkdir example
esy install
esy dune build gen
esy dune exec gen/Gen.exe ./mylib
esy build
cp _esy/default/build/install/default/lib/mylib/libmylib.so example/mylib.so
cp mylib/mylib.ts example/mylib.ts
echo "\nconsole.log('initializing ocaml module');" >> example/mylib.ts
echo "dylib.symbols.init();" >> example/mylib.ts
echo "console.log('1 + 3');" >> example/mylib.ts
echo "console.log(dylib.symbols.lib_add(1, 3));" >> example/mylib.ts
cd example
deno run --allow-ffi --unstable mylib.ts
cd ..