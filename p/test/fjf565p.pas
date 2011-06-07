program fjf565p;

type
  o = object
    function foo (a: Integer) foo: Integer;
  end;

function o.foo (a: Integer) foo: Integer;
begin
  foo := a  { WRONG, cf. fjf565o.pas }
end;

begin
end.
