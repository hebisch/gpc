{$extended-pascal}

program readdata(input, output{, inputfile});

var
        inputfile : file of char;
        temp : array[1..10] of char;

begin
        {reset(inputfile, 'test');}
        read(inputfile, temp);     { WRONG }
        {writeln(temp);
        close(inputfile);}
end.
