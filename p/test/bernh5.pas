Program Bug02;

Uses
    Bug02_U in "bernh5u.pas";

{$X+}

Var
    ProcRec : TProcRec;

Function TheName : CString;
    Begin
        TheName := 'OK';
    End;

Begin
    ProcRec.Name1 := @TheName;
    ProcRec.Name2 := @TheName;

    Write(ProcRec.Name1^[0]); { Prints out 'O' }
    WriteLn(ProcRec.Name2^[1]); { Prints out 'K' }
End.
