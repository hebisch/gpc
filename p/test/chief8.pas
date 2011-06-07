Program Chief8;

{$X+}

Procedure WriteOut ( S: pChar );

begin { WriteOut }
  write ( S^ );
  inc ( S );
  writeln ( S^ );
end { WriteOut };

begin
  WriteOut ( 'OK' );
end.
