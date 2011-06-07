program fjf786;

type
  t (n, Tag: Char) = record
                     case Tag of
                       'O': ()
                       otherwise ()
                     end;

var
  v: ^t;

begin
  New (v, 'K' { discriminant }, 'O' { also discriminant });
  WriteLn (v^.Tag, v^.n)
end.
