program fjf565q;

type
  o = object
    function foo (a: integer) = a: Integer;  { WRONG }
  end;

function o.foo (a: integer) = a: Integer;
begin
  Return 0
end;

begin
  WriteLn ('failed')
end.
