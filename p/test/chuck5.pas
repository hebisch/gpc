{$W no-identifier-case}

PROGRAM misctests(input, output);

uses GPC;

  CONST
    maxi    = 32767;
    mini    = -32768;
    maxwd   = 65535;
    maxint  = 2147483647;  (* added for portability -- Frank *)

  TYPE
    integer = mini .. maxi;
    word16  = 0 .. maxwd;

  VAR
    ch   : char;
    i, j : integer;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('Runtime error');
      Halt (0) {!}
    end
end;

{$W-, standard-pascal, ignore-garbage-after-dot, W+}

  BEGIN (* misctests *)
  AtExit (ExpectError);

  writeln('Hello, World');
  writeln('"', 'string in field of 25' : 25, '"');
  writeln(    '"1234567890123456789012345"');

(* GPC doesn't allow this anymore in CP -- Frank
  writeln('Maxint = ', maxint : 0);
  writeln('Maxi = ', maxi : -20, ' Mini = ', mini : 1);
*)
  (* disappointing that -ve field neither left justifies *)
  (* nor is flagged as an error *)
  (* My pref: 0 default, -ve for left just, +ve as usual *)

  writeln('Maxint = ', maxint : 1);
  writeln('Maxi = ', maxi : 1, ' Mini = ', mini : 1);

  writeln('Enter lines until eof');
  WHILE NOT eof DO
    IF eoln THEN BEGIN
      writeln;
      write(input^, 'Enter: new line: ' : 6);
      (* This ^ should be a blank *) (* Check truncates *)
      readln; END
    ELSE BEGIN
      output^ := input^;
      put(output);
      get(input); END;

  writeln('Fld ActualFld');
  writeln('=== ======...');
(* see above, Frank
  FOR i := -8 TO 8 DO
    writeln(i : 3, '"', maxi : i, '"');
*)
  FOR i := 1 TO 8 DO
    writeln(i : 3, '"', maxi : i, '"');

  i := maxi - 4;
(* FOR j := maxi - 3 TO maxi + 3 DO BEGIN *)
(* now throws a constant out of range error gpc321 *)
(* which is definite progress towards range checks *)
  FOR j := -3 TO +3 DO BEGIN
    i := succ(i);
    write(i : 6); (* should crash *) END;
  writeln;
  writeln(' Should have crashed here after 32767');
  END. (* misctests *)
     ^ Nothing should count after this period
(* However gpc throws errors down here *)
(* unless commented out *)
