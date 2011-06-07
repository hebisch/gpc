program fjf598c;

procedure p;
begin
end;

type
  t = procedure (s: Integer);

procedure q (v: t);
begin
end;

begin
  q (p);  { WRONG }
  WriteLn ('failed')
end.
