program fjf642i;

var
  a: function: blah;  { WRONG }

begin
  a := a;
  WriteLn ('failed')
end.
