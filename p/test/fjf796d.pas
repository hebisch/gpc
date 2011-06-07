{$borland-pascal}

{$no-ignore-packed}

program fjf796d;

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
