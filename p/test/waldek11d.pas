program spass(output);
procedure foo(protected var s : string);
begin
  if s.Capacity = 20 then
    writeln(s)
  else
    writeln('failed: ', s.Capacity)
end;

var ss : string(20);
begin
  ss := 'OK';

  foo(ss)
end
.
