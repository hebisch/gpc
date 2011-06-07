unit fjf1021u;

interface

function f: Integer;

var
  a: Integer = 42;

type
  i = Integer value f;
  j = Integer value a mod 4;

implementation

function f: Integer;
begin
  f := 0
end;

end.
