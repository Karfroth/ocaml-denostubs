#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <mylib.h>

void initialize_ocaml (char** argv) {
  caml_startup(argv);
}

int main(int argc, char **argv)
{
    initialize_ocaml(argv);
    char *world = "world";
    lib_hello(world);
    lib_add(1, 2);
}