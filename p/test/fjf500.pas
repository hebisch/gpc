(*
This fails under DJGPP with `-g'. It is triggered by the use of two
identifiers with linker name `a' (though in different scopes).

g:/.\cchaaaaa: Assembler messages:
g:/.\cchaaaaa:190: Fatal error: C_EFCN symbol out of scope

The problem can be reproduced in C (compiled with `-g' under DJGPP):

int a = 42;

void c ()
{
  void a () {}
}

But in fact it seems to be a gas problem (actually, it seems to
depend on the gas version: with 2.11, it occurs only if the variable
is initialized; with 2.9.5 it occurs only if it's not initialized.
The comment in gas/config/obj-coff.c (before the second occurrence
of `C_EFCN symbol out of scope') is not very promising, either.

Bottom line:

Apparently COFF doesn't work well with local functions WRT debug
info. DJGPP depends on COFF and "chances are [switching to ELF as
DJGPP's object file format] will never happen" (DJGPP FAQ, edition
2.30, 22.22). So, if you get this problem, just don't use `-g' or
rename your identifiers. -- With gcc-3, DJGPP seems to support Dwarf
debug info as well, so you might want to try this instead.
*)

{$if False}  { This problem should be solved with qualified identifiers }
{ @@ This disables COFF debug info. }
{$ifdef __GO32__}
{$local W-} {$disable-debug-info} {$endlocal}
{$endif}
{$endif}

{ `--no-inline-functions' is needed to provoke the problem
  (otherwise the procedures `a' and `aa' might get optimized away) }
{ FLAG --no-inline-functions }

program fjf500;

var
  a: Integer = 42;
  aa: Integer;

procedure b;
begin
end;

procedure c;

  procedure a;
  begin
  end;

  procedure aa;
  begin
  end;

begin
end;

begin
  a := a;
  aa := aa;
  WriteLn ('OK')
end.
