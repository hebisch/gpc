program fjf257b;

type
  t = record
    r : record
      s : string (2);
    end;
    b : Boolean;
  end;

const
  v : t = (r : (s : 'OK'));

begin
  { incorrect test -- this is not guaranteed if v.b = false then } writeln (v.r.s)
end.
