{ see fjf451h.pas }

{$W no-object-assignment}

program fjf451i;

type
  o = object
    a: Integer
  end;

var
  v: o;

procedure p (var x: o);
begin
  x := v  { WARN, despite `W no-object-assignment' }
end;

begin
end.
