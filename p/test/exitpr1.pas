Program ExitPr1;

uses
  ExitPr2;

Var
  SaveExitProc: Pointer;

{ Fixed: Global procedures in the main program were nested. }

Procedure MyExitProc;

begin { MyExitProc }
  ExitProc:= SaveExitProc;
  writeln ( 'K' );
end { MyExitProc };

begin
  SaveExitProc:= ExitProc;
  ExitProc:= @MyExitProc;
  write ( 'O' );
end.
