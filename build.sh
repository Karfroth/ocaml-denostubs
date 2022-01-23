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
echo "const string = new Uint8Array([...new TextEncoder().encode(\"1234567890\"),0,]);" >> example/mylib.ts
echo "const stringPtr = Deno.UnsafePointer.of(string);" >> example/mylib.ts
echo "console.log(\"pointer\", stringPtr);" >> example/mylib.ts
echo "const stringPtrRes = dylib.symbols.lib_do_nativeint_string(stringPtr);" >> example/mylib.ts
echo "const stringPtrview = new Deno.UnsafePointerView(stringPtrRes);" >> example/mylib.ts
echo "console.log(stringPtrview.getCString());" >> example/mylib.ts
cd example
deno run --allow-ffi --unstable mylib.ts
cd ..