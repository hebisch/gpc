program fjf488xn;

var a : integer = 42;

begin
  WriteLn ('failed');
  halt;
  WriteLn (SubStr (a, 1, 1))  { WRONG }
end.
