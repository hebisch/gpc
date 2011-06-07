program Emil13c;

type
  T = packed array [1 .. 10] of Void;  { WRONG }

begin
  WriteLn ('failed')
end.
