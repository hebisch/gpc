program tsmul;
var v: LongCard;
function foo(n: LongInt): LongInt;
var x : LongInt;
begin
  x := n * v;
  foo := x
end;
begin
  v := 1;
  if foo(-1) = -1 then
    writeln('OK')
  else
    writeln('failed')
end
.
