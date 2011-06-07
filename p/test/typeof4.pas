program typeof4(Output);

import GPC;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

type mystring(i, j : Integer) = record len: Integer;
                                  txt: array[1..i + j] of Char
                           end;

procedure swap(var x, y: mystring);
begin
  x := y;  { -> runtime error }
end;

var ok: mystring(3, 7) Value (2, ('O', 'K', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '));
    fail: mystring(4, 6) Value (6, ( 'f', 'a', 'i', 'l', 'e', 'd', ' ', ' ', ' ', ' '));
begin
  AtExit (ExpectError);
  swap(ok, fail);
end
.
