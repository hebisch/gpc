Unit fjf10a;

Interface

Type
  String255 = String ( 255 );

Procedure WriteString ( Const S: String );

Implementation

Procedure WriteString ( Const S: String );

begin { WriteString }
  writeln ( S );
end { WriteString };

end.
