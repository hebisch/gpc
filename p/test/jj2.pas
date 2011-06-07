program main(input,output);
var
        o, z: set of 1..15;
        oo, kk: Char value '-';
begin
        o := [1];
        z := [];
        if o < z then
                writeln('failed (1)');
        if o <= z then
                writeln('failed (2)');
        if o = z then
                writeln('failed (3)');
        if o <> z then
                oo:= pred ( 'O', 4 );
        if o >= z then
                inc ( oo );
        if o > z then
                inc ( oo );
        if z < o then
                inc ( oo );
        if z <= o then
                inc ( oo );
        if z = o then
                writeln('failed (4)');
        if z <> o then
                kk:= pred ( 'K', 3 );
        if z >= o then
                writeln('failed (5)');
        if z > o then
                writeln('failed (6)');
        if o < o then
                writeln('failed (7)');
        if o <= o then
                inc ( kk );
        if o = o then
                inc ( kk );
        if o <> o then
                writeln('failed (8)');
        if o >= o then
                write ( oo );
        if o > o then
                writeln('failed (9)');
        if z < z then
                writeln('failed (10)');
        if z <= z then
                inc ( kk );
        if z = z then
                write ( kk );
        if z <> z then
                writeln('failed (11)');
        if z >= z then
                writeln;
        if z > z then
                writeln('z > z');
end.
