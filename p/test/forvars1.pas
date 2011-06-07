Program ForVars1 ( Output );

Var
  OK: packed array [ 1..2 ] of Char;
  i: Integer;


Procedure Foo;

Var
  j: Integer;


Procedure Bar;

begin { Bar }
  OK:= 'OK';
  for j:= 1 to 2 do        { Neither accepted by ISO nor by Borland Pascal.  }
    write ( OK [ j ] );    { GPC can warn about such compatibility problems. }
  for i:= 1 to 1 do                 { Global Var accepted by BP, not by ISO. }
    for OK [ 1 ]:= 'A' to 'A' do    { Structured variable accepted by BP,    }
      writeln;                      { not by ISO which also complains about  }
end { Bar };                        { the global variable.                   }


begin { Foo }
  Bar;
end { Foo };


begin
  Foo;
end.
