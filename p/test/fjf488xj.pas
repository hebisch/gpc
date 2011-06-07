program fjf488xj;

var a : integer = 42;
    b : integer = 2;

begin
  WriteLn ('failed');
  halt;
  WriteLn (Concat (a, b))  { WRONG }
end.
