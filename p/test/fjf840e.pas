program fjf840e;

type
  t = String (100);

function f: t;
begin
  f := 'MNO'
end;

begin
  f[1 .. 2] := 'XX'  { WRONG }
end.
