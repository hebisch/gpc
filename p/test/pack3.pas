Program Pack3;

{ FLAG --borland-pascal -Werror }

Var
  FileRec: packed record
    MyFile: Text;
  end { FileRec };

  S: packed array [ 1..2 ] of Char;

begin
  with FileRec do
    begin
      Assign ( MyFile, 'pack3.dat' );
      rewrite ( MyFile );
      writeln ( MyFile, 'OK' );
      close ( MyFile );
      reset ( MyFile );
      read ( MyFile, S [ 1 ], S [ 2 ] );
      close ( MyFile );
    end { with };
  writeln ( S );
end.
