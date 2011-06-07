{ BUG: stack overflow with certain string operations }

program fjf419d;

var
  i: Integer;
  p: ^String;

begin
  New (p, 100000);
  SetLength (p^, 100000);
  i := 0;
  while i < 1000 do Inc (i, Ord (Copy (p^, 1, 1) <> ''));
  WriteLn ('OK')
end.
