program fjf929;

procedure a (c: Char);
var
  d: Char;
  f: Text;
begin
  Rewrite (f);
  WriteLn (f, c);
  if c > 'a' then a (Pred (c));
  Reset (f);
  ReadLn (f, d);
  if d <> c then
    begin
      WriteLn ('failed ', c, ' ', d);
      Halt
    end;
end;

begin
  a ('z');
  WriteLn ('OK')
end.
