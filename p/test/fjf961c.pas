{ FLAG -Wunused }

program fjf961c;

var
  t: TimeStamp;

procedure Foo (const a: TimeStamp);
begin
  Discard (a);
  WriteLn ('OK')
end;

begin
  Foo (t)
end.
