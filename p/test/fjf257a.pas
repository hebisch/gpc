program fjf257a;

type
  t = record
    r : record
      b : Boolean;
    end;
    s : string (2);
  end;

const
  v : t = (r : (); s : 'OK');

begin
  { incorrect test -- this is not guaranteed if v.r.b = false then } writeln (v.s)
end.
