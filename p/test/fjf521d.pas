program fjf521d;

type
  t = array [1 .. 10] of record
                           a: Integer;
                           b: Text;
                           c: Char
                         end;

procedure foo (a: t);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
