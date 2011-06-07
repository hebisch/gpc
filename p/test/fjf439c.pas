{ Wrong or not? Some code (ian5[ab].pas) seems to require just that. :-(
  WRONG -- Frank, 20020921 (cf. ian5m.pas) }

program fjf439c;

var bar : string (10); external name 'foo';
    bar : string (10); { WRONG }

begin
  writeln ('failed')
end.
