program init4(output);
var a : integer value 1;
function foo: integer;
begin
  foo := a;
  a := a + 1
end;
procedure bar;
var a, b, c : integer value foo;
begin
  if (a = 1) and (b = 1) and (c = 1) then begin
    writeln('OK')
  end else begin
    writeln('failed: a = ', a, ', b = ', b, ', c = ', c)
  end
end;
begin
  bar
end
.
