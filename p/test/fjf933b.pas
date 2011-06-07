program fjf933b;

type
  a (b: Integer) = record
  case 0 .. 0 of
    0: (b: Integer);  { WRONG }
  end;

begin
end.
