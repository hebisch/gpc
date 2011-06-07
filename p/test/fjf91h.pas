program fjf91h;

type
  str5 = string [5];

var
  s5: ^str5;
  s6: ^str5;

begin
  New (s5);
  s5^ := 'OK';
  s6 := s5;
  Writeln (s6^)
end.
