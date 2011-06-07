Unit Goto7U;

Interface

Implementation

Procedure BugProcedure;
    Label
        BugLabel;
    Begin
        write ( 'O' );
        Goto BugLabel;
        writeln ( 'failed' );
    BugLabel:
        writeln ( 'K' );
    End;

Begin
  BugProcedure;
End.
