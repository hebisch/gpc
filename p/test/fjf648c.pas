program fjf648c;

type
  T = file [1 .. 10] of Void;  { WRONG }

begin
  WriteLn ('failed')
end.
