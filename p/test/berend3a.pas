Program Berend3a;

Procedure Foo ( Bar: Integer );

Label
  L;

begin { Foo }
  write ( 'failed 1' );
  goto L; { WRONG -- size of S is not known at runtime(!), in case there is some
            computation between the `goto' and the `var' which modifies Bar. }
  Var S: String ( Bar );
  write ( 'failed' );
  L:
  writeln;
end { Foo };

begin
  Foo ( 42 );
end.
