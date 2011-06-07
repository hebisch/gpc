program fjf967g;

type
  t = record
        i: Integer
      end;

procedure p (protected var a: t);
begin
end;

begin
  p (t [i: 4])  { WRONG }
end.
