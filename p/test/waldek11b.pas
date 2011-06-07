program spass(output);
procedure foo(s : string);
begin
  if s.Capacity <> 1 then
    begin
      WriteLn ('failed: ', s.Capacity);
      Halt
    end
end;

var s : string(1);
begin
  s := '';
  foo('');
  foo(s);
  WriteLn ('OK')
end
.
