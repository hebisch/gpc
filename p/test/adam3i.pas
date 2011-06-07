program adam3i;

var
  f: file of Integer;
  j: Integer;

procedure at(const i: Integer);
begin
  Write (f, i)
end;

begin
  Rewrite (f);
  at (42);
  Reset (f);
  j := 0;
  Read (f, j);
  if j = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
