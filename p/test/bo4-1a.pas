Program BO4_1a;

Type
  Foo = object
    a: Integer;
  end { Foo };

begin
  writeln ( Foo.a );  { WRONG }
end.
