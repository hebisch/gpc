program fjf997b;

var
  a: Integer = 10;
  b: Integer = 100;

procedure p;
type t (n: Integer) = array [0 .. a * n + b] of Integer;
var v: ^t;
begin
  New (v, 4);
  if High (v^) <> 140 then WriteLn ('failed 1');  { 140 }
  a := 0;
  b := 0;
  if High (v^) <> 140 then WriteLn ('failed 2');  { must say 140, says 0 }
  New (v, 4);
  if High (v^) <> 140 then WriteLn ('failed 3');  { must still say 140, says 0 }
end;

begin
  p;
  WriteLn ('OK')
end.
