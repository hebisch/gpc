program fjf933d;

type
  a (b: Integer) = record
  case 0 .. 0 of
    0: (case 0 .. 0 of 0: (b: Integer));  { WRONG }
  end;

begin
end.
