{$W no-object-assignment}

program fjf884k;

type
  a = object
    c: Integer;
  end;

  b = object
    d: Integer;
  end;

procedure p (t: a);
begin
end;

var
  vb: b;

begin
  p (vb)  { WRONG }
end.
