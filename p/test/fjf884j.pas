{$W no-object-assignment}

program fjf884j;

type
  a = object
    c: Integer;
  end;

  b = object (a)
    d: Integer;
  end;

procedure p (t: b);
begin
end;

var
  va: a;

begin
  p (va)  { WRONG }
end.
