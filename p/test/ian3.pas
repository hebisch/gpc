program main(input,output);

{$L ian3m.pas}
{$init-modules=ian3m}

{ I added the linker names -- I don't think variables in implementations
  of units/modules have to be globally accessible (on the linker
  level) normally. -- Frank }

var global_int: integer; external name 'global_int';
    global_str: string(40); external name 'global_str';

procedure print_globals; external name 'print_globals';

begin
        global_int:=100;
        global_str:='OK';
        print_globals;
end.
