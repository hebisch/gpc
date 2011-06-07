program fjf768g;

type
  t = record
        s: String (6)
      end;

var
  o: t = ('OK');
  f: t = ('failed');
  p: ^t = @o;

begin
  with p^ do
    begin
      p := @f;
      WriteLn (s)
    end
end.
