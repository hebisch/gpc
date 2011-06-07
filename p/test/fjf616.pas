program fjf616;

var
  a: Integer;
  b, c: Integer absolute a;

begin
  if @a <> @b then
    begin
      WriteLn ('failed 1 ', PtrInt (@a), ' ', PtrInt (@b));
      Halt
    end;
  if @a <> @c then
    begin
      WriteLn ('failed 2 ', PtrInt (@a), ' ', PtrInt (@c));
      Halt
    end;
  a := 42;
  if b <> 42 then
    begin
      WriteLn ('failed 3 ', a, ' ', 42);
      Halt
    end;
  Inc (c);
  if a <> 43 then
    begin
      WriteLn ('failed 4 ', a, ' ', 43);
      Halt
    end;
  b := a + b + c;
  if b <> 129 then
    begin
      WriteLn ('failed 5 ', b, ' ', 129);
      Halt
    end;
  if a <> c then
    begin
      WriteLn ('failed 6 ', a, ' ', c);
      Halt
    end;
  WriteLn ('OK')
end.
