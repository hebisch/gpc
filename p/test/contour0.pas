program p;

var s: String (10) = 'OK';

label 1;

begin
  goto 1;
  s := s + 'X';
1:WriteLn (s)
end.
