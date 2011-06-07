{ EP's more reasonable behaviour (cf. fjf969a.pas) }

program fjf969c;

type
  u = array [1 .. 3] of Integer;

const
  b = u[1: 4; 2: 5; 3: 6];

begin
  b[2] := 7  { WRONG }
end.
