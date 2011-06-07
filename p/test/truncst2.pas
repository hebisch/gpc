Program TruncSt2;

{$no-truncate-strings}

Var
  Foo: String ( 3 );

begin
  {$local I-} WriteStr (Foo, 'abcdef'); {$endlocal}
  if IOResult = 0 then WriteLn ('failed') else WriteLn ('OK')
end.
