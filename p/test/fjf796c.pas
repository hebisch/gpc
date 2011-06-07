program fjf796c;

procedure Foo (var a: Char);
begin
end;

var
  a: packed record
    c: Char
  end;

begin
  Foo (a.c)  { WRONG }
end.
