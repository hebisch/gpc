{$setlimit=65536}

Program Couper08;

Type
  T_ScreenLimits = Set Of ShortCard;

Const
  XLimits : T_ScreenLimits = [0,1279];

Var
  X : ShortCard;

Begin
  X := 1279;
  If X In XLimits
  Then WriteLn('OK')
  Else WriteLn('failed')
End.
