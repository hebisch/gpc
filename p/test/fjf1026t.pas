program fjf1026t;

type
  t (b: Integer) = record
    c: Integer;
  case b of 1: (a: Integer)
  end value [case b: 1 of [a: 3]];  { WRONG }

begin
end.
