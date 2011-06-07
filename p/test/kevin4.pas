program indexseek(input, output, inputfile);

var
        inputfile : file [0..25] of char;

begin
        reset(inputfile, ParamStr (1));
        seekread(inputfile, LongInt(3));
        close(inputfile);
        writeln ( 'OK' );
end.
