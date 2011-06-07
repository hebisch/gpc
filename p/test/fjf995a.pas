program fjf995a;

type
  t (u: Char) = array [Chr (2) .. u] of Char;

var
  v: t (Chr (4));

procedure p (var a: t);
begin
  if SizeOf (a) = 4 * SizeOf (Char) then WriteLn ('OK') else WriteLn ('failed ', SizeOf (a))
end;

begin
  p (v)
end.
