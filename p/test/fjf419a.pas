{ BUG: stack overflow with certain string operations }

program fjf419a;

var
  i: Integer;
  p: ^String;

begin
  New (p, 50000);
  SetLength (p^, 50000);
  for i := 1 to 2000 do
    if p^ + p^ <> p^ + p^ then
      begin
        WriteLn ('failed');
        Halt
      end;
  WriteLn ('OK')
end.
