program typeof3(Output);
type string(i, j : integer) = record len: integer;
                                  txt: array[1..i + j] of char
                           end;
procedure swap(var x, y: string);
var tmp : type of x;
begin
  tmp := x;
  x := y;
  y := tmp
end;

var ok: string(3, 7) value (2, ('O', 'K', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '));
    fail: string(3, 7) value (6, ( 'f', 'a', 'i', 'l', 'e', 'd', ' ', ' ', ' ', ' '));
    i : integer;
begin
  swap(ok, fail);
  for i:=1 to fail.len do write(fail.txt[i]);
  writeln
end
.
