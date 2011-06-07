program Mainprg1;

uses
  u4 in 'jesper4u.pas';

procedure pp (var k : Integer);
begin
  k := 120469;
end; { pp }

begin
  { Below the procedure passed as argument (pp) resides in another    }
  { module than proc3/proc4.  The code will only compile when there   }
  { is a type cast.  This applies both to procedural parameters       }
  { (Standard Pascal) and types (Borland-like).                       }

  if ( y3 <> 2003 ) or ( y4 <> 2003 ) then
    writeln ( 'failed' )
  else
    begin

      { These lines do not compile }
      proc3 (pp);   { Line 18 }
      proc4 (pp);  { Line 19 }

      if ( y3 = 120469 ) and ( y4 = 120469 ) then
        write ( 'O' );

      { With the typecast everything works OK!  Even in the standard   }
      { Pascal version (proc3) which does not use the type "ProcType". }

      proc4 (procType (@pp));    { Bug work-around for Borland-like example   }
(*    proc3 (procType (@pp));    { It also works for Standard Pascal example  } *)

      if ( y3 = 120469 ) and ( y4 = 120469 ) then
        write ( 'K' );
      writeln;

    end (* else *);
end.
