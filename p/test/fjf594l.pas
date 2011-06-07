program fjf594l;

type
  t = ^Integer;

var
  i: restricted t;

begin
  New (i);
  i^ := 0;  { dereferencing a restricted object }   { WRONG }
  WriteLn ('failed')
end.
