Program Abso1;

Var
  OK: record
    O, K, x, y, z: Char;
  end { OK };

  {$local W-}
  x: Integer absolute OK;
  {$endlocal}
  KO: array [ 1..7 ] of Char absolute x;

begin
  Var KO2: record K, O: Char; end absolute x;
  { Fixed: `Absolute' did not work with structured types in declaring       }
  { Fixed:   statements. (Enable_keyword ("Absolute") was called too late.) }
  KO [ 1 ]:= 'O';
  KO [ 2 ]:= 'K';
  with OK do
    write ( O );
  with KO2 do
    writeln ( O );
end.
