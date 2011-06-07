program fjf1028c (Output);

type
  t = record
    case i: Integer of
      1: (b: Integer);
      2: (c: Integer;
          case k: Integer of
            3: (d: Integer value 42))
    end;

var
  v: ^t;

begin
  New (v, 2, 3);
  with v^ do
    if (i = 2) and (k = 3) and (d = 42) then WriteLn ('OK') else WriteLn ('failed ', i, ' ', k, ' ', d)
end.
