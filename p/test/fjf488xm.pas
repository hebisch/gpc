program fjf488xm;

var a : integer = 42;

begin
  WriteLn ('failed');
  halt;
  WriteLn (Copy (a, 1, 1))  { WRONG }
end.
