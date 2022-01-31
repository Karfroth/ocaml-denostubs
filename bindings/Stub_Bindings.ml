open Ctypes
open Denostubs

module Definitions: Denostubs_inverted.DEFINITIONS = struct
  let enums = []
  let structures = []
  let unions = []
  let typedefs = []
  let functions = [
    Denostubs_inverted.Func {
      name = "lib_add";
      fn_typ = (int @-> int @-> returning(void));
      fn = Lib.Util.add;
      runtime_lock = false;
      promisify = false;
    };
    Denostubs_inverted.Func {
      name = "lib_hello";
      fn_typ = (string @-> returning(void));
      fn = Lib.Util.hello;
      runtime_lock = false;
      promisify = false;
    };
    Denostubs_inverted.Func {
      name = "lib_do_nativeint_string";
      fn_typ = ((ptr void) @-> returning(ptr void));
      fn = Lib.Util.do_nativeint_string;
      runtime_lock = false;
      promisify = true;
    };
  ]
end

module Binding_Gen = Denostubs_inverted.BINDING_GEN(Definitions)
