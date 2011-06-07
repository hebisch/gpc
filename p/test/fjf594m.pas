program fjf594m;

type
  t = array [1 .. 10] of Integer;

var
  i: restricted t;

begin
  i[1] := 0;  { accessing a component of a restricted object }   { WRONG }
  WriteLn ('failed')
end.
