{$W no-object-assignment}

program fjf884l;

type
  a = object
    c: Integer;
  end;

procedure p (t: a);
begin
end;

begin
  p (42)  { WRONG }
end.
