program fjf875b;

var
  a: packed record
       b: array [1 .. 3] of Char
     end;

begin
  a.b := 'OK';
  WriteLn (a.b[1 .. 2])
end.
