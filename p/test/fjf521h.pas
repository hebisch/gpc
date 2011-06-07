program fjf521h;

type
  t = array [1 .. 10] of record
                           a: Integer;
                           b: Text;
                           c: Char
                         end;
  p = procedure (a: t);  { WRONG }

begin
  WriteLn ('failed')
end.
