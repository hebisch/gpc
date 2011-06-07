{ BUG: stack overflow with certain string operations }

program fjf419c;

var
  i: Integer;
  p: ^String;

begin
  New (p, 100000);
  SetLength (p^, 100000);
  i := 0;
  while not ((Copy (p^, 1, 1) = '') or (i = 1000)) do Inc (i);
  WriteLn ('OK')
end.
