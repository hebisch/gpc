Program Files2b;

Var
  F: File of Char;
  c: Char;
  S: Integer;

begin
  Assign ( F, 'files2.dat' );
  rewrite ( F );
  for c:= 'a' to 'f' do
    write ( F, c );
  S:= FileSize ( F );
  close ( F );
  if S <> 6 then
    writeln ( 'failed' )
  else
    begin
      reset ( F );
      read ( F, c );
      read ( F, c );
      read ( F, c );
      S:= FilePos ( F );
      if S <> 3 then
        writeln ( 'failed' )
      else
        begin
          Truncate ( F );
          S:= FileSize ( F );
          if S <> 3 then
            writeln ( 'failed' )
          else
            writeln ( 'OK' );
        end { else };
      close ( F );
    end { else };
end.
