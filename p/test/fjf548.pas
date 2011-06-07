{ The type of i changes when v varies. That can't be right.
  Applying save_expr to non-constant range bounds in
  build_pascal_range_type() solves this, but fails on schema
  discriminants used as range bounds. It might only take a check if
  the bound is constant or (an expression involving) a discriminant
  (but I don't know how), and if not, apply save_expr ... Hmm, if
  it contains both discriminants and, say, global variables, the
  latter should be evaluated now, the former not. Might be a little
  more complicated ... see also couper4.pas -- Frank }

program fjf548;

var
  v: Integer = 100;

procedure foo;
var
  i: 0 .. v;
begin
  if High (i) <> 100 then begin WriteLn ('failed 1'); Halt end;
  v := 200;
  if High (i) <> 100 then begin WriteLn ('failed 2'); Halt end
end;

begin
  foo;
  WriteLn ('OK')
end.
