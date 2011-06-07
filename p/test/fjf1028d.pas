program fjf1028d (Output);

type
  t = record
    case i: Integer of
      1: (b: Integer);
      2: (c: Integer;
          case k: Integer of
            3: (d: Integer))
    end;

var
  v: ^t;

begin
  New (v, 1, 3)  { WRONG }
end.
