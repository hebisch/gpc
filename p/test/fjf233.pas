program fjf233;

type t=integer value 42;

var
  a:array[1..100] of t;
  c:integer;

begin
  for c:=1 to 100 do
    if a[c]<>42 then
      begin
        writeln('failed');
        halt(1)
      end;
  writeln('OK')
end.
