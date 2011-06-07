program fjf1004 (Output);

type p = ^Integer;

function f = r: p;
begin
  r^ := 42
  { WRONG -- result not assigned }
end;

begin
end.
