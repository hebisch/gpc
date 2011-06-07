program mgcd_program;

var num : integer ;

begin
    num := -2147483648 ;

    if {$local W-} num = 16#80000000 then {$endlocal}
        writeln( 'failed' )
    else
        writeln( 'OK' )
end.
