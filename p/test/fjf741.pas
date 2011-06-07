program fjf741;

var
  a: Integer;
  b: foo absolute a;  { WRONG }

begin
  WriteLn ('failed')
end.
