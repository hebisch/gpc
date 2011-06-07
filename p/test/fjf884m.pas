{$W no-object-assignment}

program fjf884m;

type
  a = object
    c: Integer;
  end;

procedure p (p: Integer);
begin
end;

var
  va: a;

begin
  p (va)  { WRONG }
end.
