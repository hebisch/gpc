program fjf91b;

var
  s : String [10];

type
  str5 = String [5];

procedure p(var s : String);
begin
  writeln(s)
end;

begin
  s := 'OK';
  p(s)
end.
