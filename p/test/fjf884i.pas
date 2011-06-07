{$W no-object-assignment}

program fjf884i;

type
  a = object
    c: Integer;
  end;

var
  i: Integer;
  va: a;

begin
  i := va  { WRONG }
end.
