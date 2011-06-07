program fjf509a;

var
  s: String (10) = 'OKfailed';

begin
  Delete (s, 3, MaxInt);
  WriteLn (s)
end.
