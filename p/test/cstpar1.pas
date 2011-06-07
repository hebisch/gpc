Program CstPar1;

Procedure Ignore ( Const Foo: Char );  { passed by value }

begin { Ignore }
  Foo:= 'y';  { WRONG }
end { Ignore };


begin
  WriteLn ('failed')
end.
