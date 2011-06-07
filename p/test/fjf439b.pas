program fjf439b;

var bar : string (10); attribute (name = 'foo');
    bar : string (10); { WRONG }

begin
  writeln ('failed')
end.
