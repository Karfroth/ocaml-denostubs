const dylib = loadLib(`./mylib.so`);

console.log('initializing ocaml module');
dylib.symbols.init();
console.log('calculating 1 + 3 with ocaml');
dylib.symbols.lib_add(1, 3);
console.log('preparing string op');
const string = new Uint8Array([...new TextEncoder().encode("1234567890"),0,]);
const stringPtr = Deno.UnsafePointer.of(string);
const stringPtrview1 = new Deno.UnsafePointerView(stringPtr);
console.log("check pointer", stringPtr);
console.log('check string', stringPtrview1.getCString());
const stringPtrRes = dylib.symbols.lib_do_nativeint_string(stringPtr).then(strPtr=> {
  const stringPtrview = new Deno.UnsafePointerView(strPtr);
  console.log('result:', stringPtrview.getCString());
});
