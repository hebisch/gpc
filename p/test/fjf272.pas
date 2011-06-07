program fjf272;

var
  v : record
      case foo : boolean of
        false : (x : string (1));
        true  : (s : string (2))
      end;

  w : record
      case foo : boolean of
        false : (x : string (2));
        true  : (s : string (1))
      end;


begin
  v.foo := false;
  v.s := 'OK';
  w.foo := true;
  w.x := 'OK';
  if v.s = w.x then writeln (v.s) else writeln ('failed: ', v.s, ', ', w.x)
end.
