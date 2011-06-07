program fjf231;

type
  foo = record
    bar, baz : Integer
  end;

procedure qwe (const b : foo);
begin
end;

begin
  qwe (0); { WRONG }
  WriteLn ('failed')
end.
