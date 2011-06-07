Program Chief9;

Type
  String256 = String ( 256 );

Var
  Y : ^String256;


Procedure X  (Const s: String256);

begin { X }
  writeln ( s );
end { X };


begin
  New ( Y );
  Y^:= 'OK';
  X ( Y^ );  { <--- complains about the parameter !!}
end.
