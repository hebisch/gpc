program fjf483;

var f : File;

begin
  Rewrite (f, 1, 2); { WRONG }
  WriteLn ('failed')
end.
