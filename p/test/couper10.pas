{$setlimit=65536}

Program Couper10;

Type
  T_ScreenLimits  = Set Of ShortCard;

Var
  XLimits : T_ScreenLimits;

Var
  X : ShortCard;

Begin
  XLimits := [0,1279];
  X := 1279;
  If X In XLimits
    Then WriteLn('OK')
    Else WriteLn('failed')
End.
