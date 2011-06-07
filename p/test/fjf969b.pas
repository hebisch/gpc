{ EP's more reasonable behaviour (cf. fjf969a.pas) }

program fjf969b;

type
  t = record
    a, b: Integer
  end;

const
  a = t[a: 2; b: 3];

begin
  a.a := 4  { WRONG }
end.
