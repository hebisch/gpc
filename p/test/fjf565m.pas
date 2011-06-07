program fjf565m;

type
  o = object
    function foo (a: Integer) = bar: Integer;
  end;

function o.foo (a: Integer) = bar: Integer;
begin
  bar := a
end;

begin
  WriteLn ('OK')
end.
