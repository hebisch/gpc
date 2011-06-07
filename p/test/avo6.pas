PROGRAM BoolTest;

PROCEDURE WSSetCtlShow (showState:Boolean);
BEGIN
  if showState then WriteLn ('OK') else WriteLn ('failed')
END;

FUNCTION WSGetCtlShow:Boolean;
BEGIN
  WSGetCtlShow := False
END;

BEGIN
 WSSetCtlShow( NOT( WSGetCtlShow))
END.
