program fjf283;

procedure p (var s : string);
begin
  s := 'failed1'
end;

procedure c (const s : string);
begin
  p (s) { WRONG }
end;

var s : string (10) = 'failed2';

begin
  c (s);
  writeln (s)
end.
