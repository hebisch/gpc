program fjf1021c;

function f: Integer;
begin
  f := 0
end;

type
  i = Integer value f;
  t (n: Integer) = i;  { WRONG }

begin
end.
