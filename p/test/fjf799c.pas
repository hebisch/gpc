{$W no-near-far}

program fjf799c;

var
  far: String (2);

procedure Foo; far;
begin
  WriteLn (far)
end;

begin
  far := 'OK';
  Foo
end.
