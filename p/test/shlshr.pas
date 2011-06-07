program ShlShr;
var
  Foo: Cardinal;
begin
  Foo := 42 shl 15;
  shr (Foo, 15);
  if Foo <> 42 then
    begin
      WriteLn ('failed');
      Halt (1)
    end;
  Foo := 42;
  shl (Foo, 15);
  if Foo <> 42 shl 15 then
    begin
      WriteLn ('failed');
      Halt (1)
    end;
  WriteLn ('OK')
end.
