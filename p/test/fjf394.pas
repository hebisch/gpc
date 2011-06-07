{ FLAG --transparent-file-names }

program fjf394 (tempfile);

var
  s : String (10);
  foo, tempfile : Text;

begin
  Rewrite (foo, 'tempfile');
  WriteLn (foo, 'OK');
  Close (foo);
  Reset (tempfile);
  ReadLn (tempfile, s);
  Erase (tempfile);
  WriteLn (s)
end.
