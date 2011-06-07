{$W dynamic-arrays}

program fjf931b;

procedure p (i: Integer);
var
  s: String (20) = 'foo';
begin
  WriteLn (s[1 .. i])  { WARN }
end;

begin
  p (4)
end.
