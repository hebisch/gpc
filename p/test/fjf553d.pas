program fjf553d;

type
  r = record
    a: Integer;
    case b: Integer of
      0: (c: Integer;
          case d: Integer of
            0: (e: Integer))
  end;

var
  p: ^r;

begin
  New (p, 0, 0, 0);  { WRONG }
  WriteLn ('failed')
end.
