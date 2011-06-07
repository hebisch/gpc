program adam3o;

var
  f: file [1 .. 4] of Integer;
  i: Integer;

procedure at(const i: Integer);
begin
  SeekRead (f, i)
end;

begin
  Rewrite (f);
  Write (f, 2, 4, 6, 8);
  at (3);
  i := 0;
  Read (f, i);
  if i = 6 then WriteLn ('OK') else WriteLn ('failed')
end.
