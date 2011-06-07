program fjf143;

type
  x = object
  end;

procedure x.y; {WRONG}
begin
end;

begin
  writeln('Failed')
end.
