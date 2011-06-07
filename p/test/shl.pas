program ShlTest;

var
  a: CInteger = 1;
  i: LongestInt;

begin

  i := 1 shl (BitSizeOf (CInteger) + 3);
  if i <= 0 then begin WriteLn ('failed a1'); Halt end;
  if i shr (BitSizeOf (CInteger) + 3) <> 1 then begin WriteLn ('failed a2'); Halt end;

  i := 1 shl (BitSizeOf (MedInt) - 2);
  if i <= 0 then begin WriteLn ('failed a3'); Halt end;
  if i shr (BitSizeOf (MedInt) - 2) <> 1 then begin WriteLn ('failed a4'); Halt end;

  i := 1 shl 40;
  if i <= 0 then begin WriteLn ('failed a5'); Halt end;
  if i <> $10000000000 then begin WriteLn ('failed a6'); Halt end;

  i := a shl (BitSizeOf (CInteger) + 3);
  if i <= 0 then begin WriteLn ('failed b1'); Halt end;
  if i shr (BitSizeOf (CInteger) + 3) <> 1 then begin WriteLn ('failed b2'); Halt end;

  i := a shl (BitSizeOf (MedInt) - 2);
  if i <= 0 then begin WriteLn ('failed b3'); Halt end;
  if i shr (BitSizeOf (MedInt) - 2) <> 1 then begin WriteLn ('failed b4'); Halt end;

  i := a shl 40;
  if i <= 0 then begin WriteLn ('failed b5'); Halt end;
  if i <> $10000000000 then begin WriteLn ('failed b6'); Halt end;

  WriteLn ('OK')
end.
