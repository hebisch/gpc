{$mac-pascal}
program peter5f(output);

        type
                MyCollection = object
                        function GetDataHandle: Integer;
                end;

        function MyCollection.GetDataHandle: Integer;
        begin
                GetDataHandle := 0;
        end;

begin
        WriteLn( 'OK' );
end.

