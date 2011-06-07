program fjf142;

type
  x = object
    function y : Boolean;
  end;

function x.y : Boolean;
type
  r = record
    i : Integer
  end;
begin
  y := True  { GPC crashes here with fatal signal 11, triggered by the
               declaration of r }
end;

var a:x;
begin
  if a.y then writeln('OK') else writeln('Failed')
end.
