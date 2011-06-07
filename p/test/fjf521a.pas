program fjf521a;

type
  t = Text;

procedure foo (a: t);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
