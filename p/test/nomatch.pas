Program NoMatch;

Procedure Foo ( Bar: Integer ); forward;

{ Fixed: Mismatches in forward declared headers were not detected. }

Procedure Foo ( Bar: Real );  { WRONG }

begin { Foo }
end { Foo };

begin
  writeln ( 'failed' );
end.
