{$pack-struct}

program fjf797a;

procedure Foo (var a: Char);
begin
  WriteLn (a, 'K')
end;

var
  a: record
    c: Char
  end;

begin
  a.c := 'O';
  Foo (a.c)
end.
