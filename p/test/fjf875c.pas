program fjf875c;

var
  a: packed record
       b: array [1 .. 3] of Char
     end;
  s: String (1) = 'O';

begin
  a.b := s + 'K';
  WriteLn (a.b[1 .. 2])
end.
