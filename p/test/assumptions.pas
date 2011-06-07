{ FLAG -w }

{ From: "Pascal Compiler Validation"                 }
{       by Brian A. Wichmann and Z. J. Ciechanowicz  }
{       ISBN 0 471 90133 4                           }

{ The purpose of this program is to check that the
  basic requirements for running the testsuite are met by
  an implementation. It does not form part of the test
  suite, but is an aid to avoid problems with the suite
  when running all the programs.
}
program Assumptions(output);

const
   curlybracket = '{';
   squarebracket = '[';
   basicset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()<>+-/*=.,:;@ ''';

type
   charset = packed array [1 .. 52] of char;
   reason = packed array [1 .. 52] of char;
   smallset = set of 0 .. 15;

var
   chars: charset;
   i, j: 1 .. 52;
   sset: smallset;
   localfile: text;
   max: integer;
   one: real;

procedure fail(s: reason);
begin
   writeln;
   writeln('BASIC REQUIREMENT NOT MET: REASON');
   writeln('     ', s);
end;

begin
   { check all basic characters distinct }
   chars := basicset;
   for i:= 1 to 51 do
      for j := i+1 to 52 do
         if chars[i] = chars[j] then
            fail('CHAR SET TOO SMALL');

   { check line length of 72 characters accepted }
   i :=
   000000000000000000000000000000000000000000000000000000000000000000000001
   ;
   if i <> 1 then
      fail('LINE LENGTH < 72');

   { check line length of 72 accepted, constructed by substitution }
   {{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{1}
   i := 2 ; { in case closing bracket missed }
   if i <> 2 then
      fail('LINE   (* < 72 CHARS');

   { check 72 charcters accepted as output to textfile }
   writeln('CHECK NEXT LINE HAS 72 CHARS');
   for i := 1 to 9 do
      write('12345678');
   writeln;
   writeln('END OF LINE');

   { check maxint big enough }
   if maxint <= 32000 then
      fail('MAXINT TOO SMALL');

   { check reals are accurate enough }
   if 1.001 <= 1.0 then
      fail('REAL TOO INACURATE');

   { check that small sets are permitted }
   sset := [0 .. 15];
   sset := sset - [1 .. 14];
   if sset <> [0, 15] then
      fail('SMALL SETS INCORRECT');

   { check local files implemented }
   rewrite(localfile);
   writeln(localfile, maxint, '  ', 1.0);
   reset(localfile);
   read(localfile, max, one);
   if (max <> maxint) or (one <> 1.0) then
      fail('LOCAL FILES INCORRECT');

   writeln(' CURLY BRACKET IS ', curlybracket);
   writeln('SQUARE BRACKET IS ', squarebracket);
end.
