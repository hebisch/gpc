{ COMPILE-CMD: asmtest.cmp }

{ Formerly asmtest.pas, asmtest2.pas, asmtest3.pas and dario.pas.
  Merged to reduce the number of redundant "SKIPPED" messages on
  non-supported targets. (Since all are "OK" tests, merging is safe.)
  -- Frank, 20030929 }

{$implicit-result}

Program AsmTest;

Type
  S2 = packed array [ 1..2 ] of Char;

var
  Test, OK: S2;
  O, K: Integer;


Function GetOK: S2;

begin { GetOK }

  { IA32 }
  asm ( 'movw %1, %0'
        : '=r' ( Result )
        : 'rm' ( Test ) );

end { GetOK };


Function GetOK2: S2;

begin { GetOK2 }

  { IA32 }
  asm ( 'movw %1, %0'
        : '=' 'r' ( Result )
        : 'r' "m" ( Test ) );

end { GetOK2 };


var this: packed array [1..30] of Char;
    does: Integer value 30 div SizeOf ( Integer );
    work: Integer value ord ( 'O' ) + ord ( 'K' ) shl 8;

procedure I_am_happy_because (var dest; count, fill_value: Integer);
var dummy : pointer;
begin

  { IA32 }
  asm volatile ('cld'
       'rep'
       'stosl'
       : '=c' (count), '=D' (dummy)
       : '0' (count), 'a' (fill_value), '1' (@dest)
       : 'cc', 'memory' );

end;

var
  n: Integer = 0;
  IsOK: Boolean = True;

procedure Check (const s: String);
begin
  Inc (n);
  if s <> 'OK' then
    begin
      WriteLn ('failed ', n, ': ', s);
      IsOK := False
    end
end;

begin
  Test:= 'OK';
  OK:= GetOK;
  Check ( OK );

  { IA32 }
  asm ( 'movl %%eax,%0'
        'movl %%edx,%1'
        : '=rm' ( O ), '=rm' ( K )
        : 'a' ( 79 ), 'd' ( 75 ) );

  Check ( chr ( O ) + chr ( K ) );

  Test:= 'OK';
  OK:= GetOK2;
  Check ( OK );

  I_am_happy_because(this, does, work);
  Check ( this [ 5..6 ] );

  if IsOK then WriteLn ('OK');
  { Just check that "simple" form is accepted }
  asm ('nop');
end.
