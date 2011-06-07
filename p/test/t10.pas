program expon2(output);
var
        pi, spi: real;

function power(x: real; y: integer): real;
        var
                z: real;
        begin
                z := 1;
                while y>0 do
                begin
                        while not odd(y) do
                        begin
                                y := y div 2;
                                x := sqr(x);
                        end;
                        y := y-1;
                        z := x*z;
                end;
                power := z;
        end;
begin
        pi := 3.14159;
        writeln(2.0:0:10, 7:2, power(2.0, 7):15:10);
        spi := power(pi, 2);
        writeln(pi:0:10, 2:2, spi:15:10);
        writeln(spi:0:10, 2:2, power(spi, 2):15:10);
        writeln(pi:0:10, 4:2, power(pi, 4):15:10);
end.
