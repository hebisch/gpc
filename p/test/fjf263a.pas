program fjf263a;

function foo (var t : String) : boolean;
begin
  t := 'OK';
  foo := true
end;

function bar (s : String) : boolean;
begin
  writeln (s);
  bar := true
end;

var
  t: String (10);
  Dummy: Integer;

begin
  t := 'failed';
  if foo (t) and bar (t) then Dummy := 1;
end.
