program fjf389;

type
  Foo (i : Integer) = array [1 .. i] of Integer;

var
  f : File of Foo; { WRONG }

begin
  WriteLn ('failed')
end.
