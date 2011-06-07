program fjf648d;

type
  T = packed file [1 .. 10] of Void;  { WRONG }

begin
  WriteLn ('failed')
end.
