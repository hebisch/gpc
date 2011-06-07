Module Sven14cu Interface;

Export
  Sven14ci = ( OK, Init );

Var
  OK: String ( 2 );

Procedure Init;

end.


Module Sven14cu Implementation;

Var
  KO: String ( 2 );

Procedure Init;

begin { Init }
  KO:= 'OK';
  OK:= KO;
end { Init };

end.
