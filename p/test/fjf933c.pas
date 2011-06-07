program fjf933c;

type
  a = record
    b: Integer;
  case 0 .. 0 of
    0: (case 0 .. 0 of 0: (b: Integer));  { WRONG }
  end;

begin
end.
