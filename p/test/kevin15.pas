program readchar(input, output, inputfile);

var
        inputfile : file of char;
        letter : char;
        i : integer;

begin
        reset(inputfile, '');
        seekread(inputfile, 3);
        writeln(inputfile^);
        for i := 1 to 5 do
        begin
          read(inputfile,letter);
          writeln(letter);
        end;
        close(inputfile);
end.
