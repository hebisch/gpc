program fjf318a;

procedure check (const a : String);
var
  s : String (5000);
  i : Integer = 0; attribute (static);
begin
  inc (i);
  Read (s);
  if not eof then readln;
  if s <> a then
    begin
      writeln ('failed ', i, ' ', a, ' ', s);
      halt
    end
end;

var
  i: Integer;
  s: String (5000);

begin
  check ('foo'#0'foo');
  check ('bar');
  SetLength (s, 4000);
  for i := 1 to 4000 do s[i] := 'a';
  check (s);
  check ('kukkuu');
  writeln ('OK')
end.
