program fjf1028b (Output);

type
  t (a: Integer) = record
    case Integer of
      a: (b: Integer)  { WRONG }
    end;

begin
end.
