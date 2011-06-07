program fjf257c;

type
  t = record
    r : record
      s : string (2);
    end;
    b : Boolean;
  end;

const
  v : t = (r : (s : 'OK'); b : true);

begin
  if v.b = true then writeln (v.r.s) else writeln ('failed')
end.
