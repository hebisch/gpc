program fjf971b;

type
  t = record
    i: Integer;
    c: Char
  end;

const
  a = t[i, c: 42];  { WRONG }

begin
end.
