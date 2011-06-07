program spass(output);
procedure foo(protected s : string);
begin
  if s.Capacity = 2 then
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
