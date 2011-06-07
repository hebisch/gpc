program fjf553c;

type
  r = record
    a: Integer;
    case b: Integer of
      4: (c: Integer;
          case d: Integer of
            2: (e: Integer))
  end;

var
  p: ^r;

begin
  New (p, 4, 2);
  if (p^.b = 4) and (p^.d = 2) then WriteLn ('OK') else WriteLn ('failed')
end.
