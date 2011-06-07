unit fjf278u;

interface

type
  o = object
    function f: Integer;
  end;

var f : string (2) = 'OK';

implementation

function o.f: Integer;
begin
  f := 0
end;

end.
