program fjf348;

var
  f : Text;

{$I-}

begin
  Reset (f, 'non/existent/directory/foo/bar/baz');
  if IOResult = 0 then
    begin
      WriteLn ('failed: Reset');
      Halt (1)
    end;
  Rewrite (f, 'non/existent/directory/foo/bar/baz');
  if IOResult = 0 then
    begin
      WriteLn ('failed: Rewrite');
      Halt (1)
    end;
  Extend (f, 'non/existent/directory/foo/bar/baz');
  if IOResult = 0 then
    begin
      WriteLn ('failed: Extend');
      Halt (1)
    end;
  WriteLn ('OK')
end.
