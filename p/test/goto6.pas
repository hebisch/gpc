Program Goto6;

{$W-}

Label
  Bar;

Procedure Foo;

Label
  Bar;

begin { Foo }
  write ( 'K' );
  goto Bar;
  write ( 'failed' );
  Bar:
end { Foo };

begin
  write ( 'O' );
  Foo;
  if 1 = 42 then
    begin
      Bar:
      writeln ( 'failed' );
    end { if }
  else
    writeln;
end.
