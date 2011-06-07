Program Bernhard3;

Type
    PEntry = ^TEntry;
    TEntry = Record
        Prev : PEntry;   { Linked List }
        Data : Word;
    End;

    TObj = Object
        Index : PEntry;

        Procedure DisposeIndex;
    End;

Procedure TObj.DisposeIndex;

    Procedure DisposeEntry(Var Entry:PEntry);
        Begin
            If (Entry <> Nil) Then
                Begin
                    DisposeEntry(Entry^.Prev);
                    Dispose(Entry);
                    Entry := Nil;
                End;
        End;

    Begin
        DisposeEntry(Index);
    End;

Begin
  writeln ( 'OK' );
End.
