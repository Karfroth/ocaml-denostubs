#! /bin/sh
rm -rf example
mkdir example
dune build
cp _build/install/default/lib/mylib/libmylib.so example/mylib.so
cp _build/install/default/lib/mylib/mylib.ts example/mylib.ts
chmod +rw example/mylib.ts

# adding some init code to ts file
echo "" >> example/mylib.ts
cat ts_rest.ts >> example/mylib.ts
cd example
deno run --allow-ffi --unstable mylib.ts
cd ..