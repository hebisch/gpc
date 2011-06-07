program fjf745h;

type
  t = record
      case c: Char of
        ' ': (a: Integer)
      end;

var
  v: ^t;

begin
  New (v, '');  { WRONG }
  WriteLn ('failed')
end.
