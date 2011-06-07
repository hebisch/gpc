Program StrBool;

(* FLAG --borland-pascal *)

Var
  S: String;

begin
  Str ( false, S );  { WARN }
  writeln ( 'failed' );
end.
