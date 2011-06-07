Program Files2;

Var
  F: Text;
  C: Char;
  S: Integer;

begin
  Assign ( F, 'files2.dat' );
  rewrite ( F );
  write ( F, 'abcdef' );
  S:= FileSize ( F );
  close ( F );
  if S <> 6 then
    writeln ( 'failed' )
  else
    begin
      reset ( F );
      read ( F, C );
      read ( F, C );
      read ( F, C );
      S:= FilePos ( F );
      if S <> 3 then
        writeln ( 'failed' )
      else
        writeln ( 'OK' );
      close ( F );
    end { else };
end.
