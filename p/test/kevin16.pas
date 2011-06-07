program indexseek(input, output, inputfile);

var
        inputfile : file [0..25] of char;
        index : integer = 3;   
begin
        reset(inputfile, ParamStr (1));
        seekread(inputfile, 3);
        seekread(inputfile, index);
        close(inputfile);
        WriteLn ('OK')
end.
