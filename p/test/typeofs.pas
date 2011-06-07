Program TypeOfs;

Type
  APtr = ^AObj;
  BPtr = ^BObj;

AObj = object
  A: Integer;
  Constructor Init;
end { AObj };

BObj = object ( AObj )
  B: Real;
end { BObj };

Var
  A: AObj;
  B: BObj;
  p: APtr;

Constructor AObj.Init;

begin { AObj.Init }
end { AObj.Init };

begin
  B.Init;
  { GPC extensions: explicit assignment to TypeOf }
  {$X+} SetType ( A, TypeOf ( AObj ) ); {$X-}
  p:= @B;
{
  writeln ( Integer ( TypeOf ( AObj ) ) );
  writeln ( Integer ( TypeOf ( BObj ) ) );
  writeln ( Integer ( TypeOf ( A ) ) );
  writeln ( Integer ( TypeOf ( B ) ) );
  writeln ( Integer ( TypeOf ( p^ ) ) );
}
  if ( TypeOf ( A ) = TypeOf ( AObj ) )
     and ( TypeOf ( p^ ) = TypeOf ( BObj ) ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
