program fjf994c;

function f: Integer; attribute (ignorable = 1);  { WRONG }
begin
  f := 42
end;

begin
end.
