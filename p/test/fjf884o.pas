program fjf884o;

type
  a = object
    b: Integer
  end;

var
  w: a;

function p = v: a;  { WARN }
begin
  v := w
end;

begin
end.
