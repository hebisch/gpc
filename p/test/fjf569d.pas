program fjf569d;

type
  t = set of 0 .. 255;

procedure Test (protected s: t);
begin
  s := []  { WRONG }
end;

begin
  Test ([5, 7]);
  WriteLn ('failed')
end.
