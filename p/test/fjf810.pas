program fjf810;

type
  t = record end;

operator <> (a, b: t) = c: Boolean;
begin
  c := False
end;

var
  s: String (2) = 'OK';

begin
  if s <> '' then WriteLn (s)
end.
