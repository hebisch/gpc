{ BUG: stack overflow with certain string operations }

program fjf419b;

var
  i: Integer;
  p: ^String;

begin
  New (p, 100000);
  SetLength (p^, 100000);
  i := 0;
  repeat
    Inc (i)
  until (Copy (p^, 1, 1) = '') or (i = 1000);
  WriteLn ('OK')
end.
