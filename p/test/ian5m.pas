(* The header include mechanism is rather un-Pascalish. The way it
   was used contradicts the rules of Pascal (declaring something
   first as `external' and then regularly, such as C programs do).

   The proper mechanism for modularization in Pascal are EP style
   modules and BP style units (cf. ian5c.pas), which are both well
   supported by GPC and syntactically easier, both in the module/unit
   and the importing program.

   Therefore, it does not seem justified to support another mechanism
   at the cost of proper declaration checking (which is not complete
   in GPC as of this writing, but should improve).

   So if you want to still use this mechanism, you'll have to do some
   extra work now, as shown here. The purpose of `external' in the
   old code was apparently to guarantee a matching external name in
   both the program and the module (which is automatic when using
   modules/units the proper way, but with `external' it is only a
   side effect which may even disappear in the future).

   Note: The use of C style `#foo' directives is not mandatory (we
   recommend BP style `{$foo}' directives instead), but since they
   were used in the original example, and the whole thing is rather
   Cish, anyway, I leave them in.

   -- Frank, 20020921 *)

{
Old code:

module lib(input,output);

#include "ian5.inc"

var s:string(40);

procedure print_globals;
begin
 writeln(s);
end;

end.
}

module lib(input,output);

var s:string(40); attribute (name = 'S');

procedure print_globals; attribute (name = 'Print_globals');
begin
 writeln(s);
end;

end.
