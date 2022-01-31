let generate dirname =
  let prefix = "mylib" in
  let path basename = Filename.concat dirname basename in
  let ml_fd = open_out (path "mylib_bindings.ml") in
  let c_fd = open_out (path "mylib.c") in
  let h_fd = open_out (path "mylib.h") in
  let ts_fd = open_out (path "mylib.ts") in
  let deno_fd = open_out (path "deno_init.c") in
  let module Cstubs_bindings = Bindings.Stub_Bindings.Binding_Gen.CStubs_bindings in
  let module Denostubs_bindings = Bindings.Stub_Bindings.Binding_Gen.Denostubs_bindings in
  begin
    (* Generate the ML module that links in the generated C. *)
    Cstubs_inverted.write_ml 
      (Format.formatter_of_out_channel ml_fd) ~prefix (module Cstubs_bindings);

    (* Generate the C source file that exports OCaml functions. *)
    Format.fprintf (Format.formatter_of_out_channel c_fd)
      "#include \"mylib.h\"@\n%a"
      (Cstubs_inverted.write_c ~prefix) (module Cstubs_bindings);

    (* Generate the C header file that exports OCaml functions. *)
    Cstubs_inverted.write_c_header 
      (Format.formatter_of_out_channel h_fd) ~prefix (module Cstubs_bindings);

    Denostubs.write_ts (Format.formatter_of_out_channel ts_fd) (module Denostubs_bindings);
    Denostubs.write_deno_c_stub (Format.formatter_of_out_channel deno_fd);

  end;
  close_out h_fd;
  close_out c_fd;
  close_out ml_fd

let () = generate (Sys.argv.(1))