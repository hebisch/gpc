Program PackedAssignTest;
Uses martin3u;

Var I,J:Integer;
    APackedBoolean:TPackedBoolean;
Begin
 for I := 1 to MaxA do
   for J := 1 to MaxB do
     APackedBoolean[I, J] := J = I + 1;
 ARecord.C:=99;
 ARecord.D:=100;
 ARecord.PackedBoolean:=APackedBoolean;
 for I := 1 to MaxA do
   for J := 1 to MaxB do
     if ARecord.PackedBoolean[I, J] <> (J = I + 1) then
       Begin
         WriteLn ('failed ', I, ' ', J);
         Halt
       end;
 if (ARecord.D = 100) and (ARecord.C = 99) then WriteLn ('OK') else WriteLn ('failed 2')
end.
