{$mac-pascal}
program peter5d(output);

        type
                obj = object
                        procedure Destroy;
                end;

        procedure obj.Destroy;
        begin
                dispose( self );
        end;

        var
                o: obj;
begin
        new(o);
        o.Destroy;
        WriteLn( 'OK' );
end.

