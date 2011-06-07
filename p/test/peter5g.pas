program peter5g(output);
{$define member(a,b) ((a) is b)}
{$mac-objects}
        type
                ObjectBase = object
                        procedure Doit;
                end;
                ObjectA = object(ObjectBase)
                        procedure Doit; override;
                end;
                ObjectB = object(ObjectBase)
                        procedure Doit; override;
                end;

        procedure ObjectBase.Doit;
        begin
        end;
        procedure ObjectA.Doit;
        begin
        end;

        procedure ObjectB.Doit;
        begin
        end;

var
        base, a, b: ObjectBase;
        ao: ObjectA;
        bo: ObjectB;
begin
        New(base);
        New(ao);
        New(bo);
        a := ao;
        b := bo;
        {$local W-}
        if member( base, ObjectBase ) and not member( base, ObjectA )
          and not member( base, ObjectB ) and member( a, ObjectBase )
          and member( a, ObjectA ) and not member( a, ObjectB )
          and member( b, ObjectBase ) and not member( b, ObjectA )
          and member( b, ObjectB ) {$endlocal} then begin
                WriteLn( 'OK' );
        end else begin
                WriteLn( 'failed' );
        end;
end.

