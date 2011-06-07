{TEST 6.6.5.2-3, CLASS=CONFORMANCE}

{ This program tests if true is assigned to eof if the file f
  is empty when reset. }

program t6p6p5p2d3(output);
var
   fyle : text;
begin

   { This `rewrite' call was missing in the test program as I
     found it. However, according to a short discussion in
     comp.lang.pascal.ansi-iso (<3C004F05.75B683F0@yahoo.com>),
     the test is at best implementation dependent, and probably
     entirely wrong without it, so I'm adding it. -- Frank }
   rewrite(fyle);

   reset(fyle);
   if eof(fyle) then
      writeln('OK')
   else
      writeln(' FAIL...6.6.5.2-3')
end.
