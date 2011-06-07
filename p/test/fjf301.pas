program fjf301;

type s = string (42);

function foo : s;
begin
  foo := 'OK'
end;

procedure bar (x : cstring);
begin
  writeln (cstring2string (x))
end;

begin
  bar (foo)
end.
