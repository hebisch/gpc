program fjf91a; { WRONG }

var
  s : string [10];

type
  str5 = string [5];

procedure p(var s : str5);
begin
  writeln('Failed')
end;

begin
  p(s)
end.
