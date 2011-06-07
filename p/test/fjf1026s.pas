program fjf1026s;

type
  t = record
        c: Integer;
      case b: Integer of 1: (a: Integer)
      end value [case c: 1 of [a: 3]];  { WRONG }

begin
end.
