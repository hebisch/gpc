module ian3m(input,output);

procedure print_globals; attribute (name = 'print_globals'); forward;

var global_int:integer;               attribute (name = 'global_int');
    global_str:string(40);            attribute (name = 'global_str');

procedure print_globals;
begin
        if global_int = 100 then
          writeln ( global_str )
        else
          writeln ( 'failed' )
end;

end.
