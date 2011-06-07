program fjf675;

type
  t = record
    a: Integer;
    b, c: String (100);
  end;

const
  c: t = (42, 'K', 'NOP');

begin
  with c do
    if a = 42 then WriteLn (c[2], b) else WriteLn ('failed')
end.
