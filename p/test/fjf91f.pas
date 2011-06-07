program fjf91f; { WRONG }

type
  str5 = string [5];
  str6 = string [6];

var
  s5: ^str5;
  s6: ^str6;

begin
  New (s5);
  s6 := s5;
  WriteLn ('failed')
end.
