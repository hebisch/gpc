{ I have no idea why someone might want to use a conformant array of untyped
  files, but I see no reason to forbid it syntactically, as was done, as it
  doesn't cause any conflicts. }

program fjf1069 (Output);

procedure p (var a: array [m .. n: Integer] of file);
begin
end;

begin
  WriteLn ('OK')
end.
