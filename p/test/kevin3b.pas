program readdata(input, output{, inputfile});

var
        inputfile : file of char;
        temp : array[1..10] of char;

begin
        writeln ('OK');
        exit;
        reset(inputfile, 'test');
        read(inputfile, temp);     { allowed, as strings and chars are assignment-compatible }
        writeln(temp);
        close(inputfile);
end.
