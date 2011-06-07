program fjf997a (Output);

type
  t (n: Integer) = 1 .. n;

var
  c: Boolean = False;

function f: Integer;
begin
  if c then WriteLn ('failed 1');
  c := True;
  f := 42
end;

var
  v: t (f);

begin
  if (High (v) = 42) and (v.n = 42) then WriteLn ('OK') else WriteLn ('failed ', High (v), ' ', v.n)
end.
