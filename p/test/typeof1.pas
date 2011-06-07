program typeof1(Output);
procedure swap(var x, y: string);
var tmp : type of x;
begin
  tmp := x;
  x := y;
  y := tmp
end;

var ok: string(10) value 'OK';
    fail: string(10) value 'failed';
begin
  swap(ok, fail);
  writeln(fail)
end
.
