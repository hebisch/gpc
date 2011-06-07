{$W no-object-assignment}

program fjf884q;

type
  a = abstract object
    c: Integer
  end;

  b = object (a)
  end;

var
  w: b;

function p = v: a;  { WRONG }
begin
  v := w
end;

begin
end.
