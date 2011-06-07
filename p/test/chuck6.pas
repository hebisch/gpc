{$W-}
 PROGRAM uicheck(input, output);

   TYPE
     unsigned = 0 .. maxint;

   VAR
     a, b     : unsigned;
     delta    : integer;

   BEGIN
   a := 10; b := 20;
   delta := a - b; writeln(delta);
   delta := b - a; writeln(delta);
   writeln(a - b : 12, b - a : 12);

   (* this gives evil results and warns, but is legal *)
   writeln(ord(a) - ord(b) : 12, ord(b) - ord(a) : 12);

   (* This seems to pass - ord has no effect warnings *)
   delta := ord(b) - ord(a);
   if delta <> 10  THEN writeln('fails');
   delta := ord(a) - ord(b);
   if delta <> -10 THEN writeln('fails');
   END.
