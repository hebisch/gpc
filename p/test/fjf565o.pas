program fjf565o;

type
  o = object
    function foo (a: Integer) = foo: Integer;
  end;

function o.foo (a: Integer) = foo: Integer;
begin
  foo := a  { WRONG! The result variable is shadowed by `[Self.]foo', and
              since `foo' has the result variable, assignments to the
              function-identifier are not allowed. }
end;

begin
end.
