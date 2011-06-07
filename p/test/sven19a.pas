program sven19a;

TYPE    vektor(n: integer)=array[0..n-1]of double;

        vektorarray(n: integer)=array[1..100]of vektor(n);

VAR     a: ^vektorarray;
    i: integer;

BEGIN   new(a, 3);
 if a^.n <> 3 then BEGIN writeln ('failed 1: ', a^.n); halt (1) END;
 for i := 1 to 100 do
   if a^[i].n <> 3 then BEGIN writeln ('failed 2: ', i, ' ', a^[i].n); halt (1) END;
 if (Sizeof(a^) < 300 * Sizeof (double) + 101 * Sizeof (integer)) and (Sizeof(a^) > 300 * Sizeof (double) + 101 * Max (Sizeof (integer), AlignOf (double))) then BEGIN writeln ('failed 3: ', Sizeof(a^)); halt (1) END;
 for i := 1 to 100 do
   if (Sizeof(a^[i]) < 3 * Sizeof (double) + Sizeof (integer)) and (Sizeof(a^[i]) > 3 * Sizeof (double) + Max (Sizeof (integer), AlignOf (double))) then BEGIN writeln ('failed 4: ', i, ' ', Sizeof(a^[i])); halt (1) END;
 writeln ('OK')
END.
