Program fjf58a;

Type
  Foo = record
    case Integer of
      'A': ( B: Byte; )  { WRONG }
  end { Foo };

begin
  writeln ( 'failed' );
end.
