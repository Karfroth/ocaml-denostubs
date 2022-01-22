#! /bin/sh
rm -rf example
mkdir example
dune build
cp _build/install/default/lib/mylib/libmylib.so example/mylib.so
cp _build/install/default/lib/mylib/mylib.ts example/mylib.ts
chmod +rw example/mylib.ts

# adding some init code to ts file
echo "" >> example/mylib.ts
echo "const dylib = loadLib(\`./mylib.so\`);" >> example/mylib.ts
echo "console.log('initializing ocaml module');" >> example/mylib.ts
echo "dylib.symbols.init();" >> example/mylib.ts
echo "console.log('1 + 3');" >> example/mylib.ts
echo "dylib.symbols.lib_add(1, 3);" >> example/mylib.ts
cd example
deno run --allow-ffi --unstable mylib.ts
cd ..