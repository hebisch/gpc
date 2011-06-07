Program Sven0;

Var
  OK: String ( 2 ) = 'OK';


{ FIXED: Initialized absolute variables -> GPC crash. }


Procedure WriteOut ( Var X );

Var
  S: String ( 255 ) absolute X;

begin { WriteOut }
  writeln ( S );
end { WriteOut };


begin
  WriteOut ( OK );
end.
