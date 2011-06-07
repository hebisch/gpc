program fjf927b;

const
  c: array [1 .. 2] of Integer = ((), ();  { WRONG }

begin
  WriteLn (ParamStr (0))  { crashed }
end.
