program fjf432;

var
  s : String (10);

begin
  if ParamStr (1) <> 'bar' then
    begin
      WriteLn ('failed: ParamStr (1) = ', ParamStr (1));
      Halt
    end;
  if EOF then
    begin
      WriteLn ('failed: EOF 1');
      Halt
    end;
  ReadLn (s);
  if s <> 'foo' then
    begin
      WriteLn ('failed: s1 = ', s);
      Halt
    end;
  if EOF then
    begin
      WriteLn ('failed: EOF 2');
      Halt
    end;
  ReadLn (s);
  if s <> 'baz' then
    begin
      WriteLn ('failed: s2 = ', s);
      Halt
    end;
  if not EOF then
    begin
      WriteLn ('failed: not EOF 3');
      Halt
    end;
  WriteLn ('OK')
end.
