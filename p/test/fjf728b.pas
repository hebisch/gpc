program fjf728b;

var a: integer;
    q: record x: (a, b, c, d, e);  { WRONG }
              y: b .. d
       end;

begin
  WriteLn ('failed')
end.
