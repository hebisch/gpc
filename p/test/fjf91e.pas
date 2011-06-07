program fjf91e;

type
  str5 = string [5];

var
  s : str5;

procedure p(var s : str5);
begin
  writeln(s)
end;

begin
  s := 'OK';
  p(s)
end.
