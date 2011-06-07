Program FunnyBug;

Type
    PArray = ^TArray;
    TArray = Array[0..255] Of Integer;
Var
    I : Integer;
    A : PArray;
Begin
    New(A);
    For I := 0 To 255 Do
        Begin
            A^[I]   := 10;
            A^[(I)] := 10;  { :-) }
        End;
    Dispose(A);
    writeln ( 'OK' );
End.
