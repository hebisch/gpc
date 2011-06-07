program fjf840b;

type
  t = String (100);

function f: t;
begin
  f := 'MNO'
end;

begin
  f[1] := 'X'  { WRONG }
end.
