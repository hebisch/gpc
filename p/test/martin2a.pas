{ Failed on strict alignment platforms. }

Program TCS_Test3;

{ Using a unit triggers the problem }
Uses martin2u;

Var J,K:Integer;
    AFile:File [1..3] of TCompr;

Begin
 Rewrite(AFile);
 For J:=1 To 3 Do
  Begin
   SeekWrite(AFile,J);
   With AFile^ Do
    Begin
     AClass:=J;
     Awel:=[J];
    End;
   Put(AFile);
  End;
 Reset(AFile);
 For J:=1 To 3 Do
  Begin
   With AFile^ Do
    Begin
     If AClass <> J then
       Begin
         WriteLn ('failed AClass ', J, ' ', AClass);
         Halt
       End;
     For K:=1 To 40 Do
       If (K in Awel) <> (K = J) then
         Begin
           WriteLn ('failed Awel ', J, ' ', K);
           Halt
         End;
    End;
   Get(AFile);
  End;
 WriteLn ('OK')
End.
