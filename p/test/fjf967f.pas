program fjf967f;

type
  t = record
        i: Integer
      end;

procedure p (var a: t);
begin
end;

begin
  p (t [i: 4])  { WRONG }
end.
