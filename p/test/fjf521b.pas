program fjf521b;

type
  t = file;

procedure foo (a: t);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
