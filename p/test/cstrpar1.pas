Program CStrPar1;


{ "String" parameter: passing as "CString" parameters doesn't work . }


Procedure Puts ( S: CString ); external name 'puts';


Procedure KO ( Var R: Integer; S, T: CString );

begin { KO }
  Puts ( S );
end { KO };


Procedure OK ( S: String );

Var
  Foo: Integer;

begin { OK }
  KO ( Foo, S, 'foo' );
end { OK };


begin
  OK ( 'OK' );
end.
