program test(output);
var
x :real;

function expo(a:real):integer;
begin
  if a=0 then
    expo:=0
  else
    expo:=round(ln(abs(a))/ln(10)-0.49999)
end;

begin
while not eof do begin
        readln(x);
        writeln(expo(x):10)
        end
end.
