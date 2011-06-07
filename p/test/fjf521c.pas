program fjf521c;

type
  t = file of Integer;

procedure foo (a: t);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
