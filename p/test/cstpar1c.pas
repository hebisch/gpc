Program CstPar1c;

Procedure Ignore ( protected Foo: Char );  { passed by value }

begin { Ignore }
  Foo:= 'y';  { WRONG }
end { Ignore };


begin
  WriteLn ('failed')
end.
