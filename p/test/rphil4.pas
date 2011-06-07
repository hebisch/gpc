PROGRAM Test;
TYPE
    Colors    = (Yellow, Orange, Red, Purple, Green);

VAR
    ThisColor : Colors;

BEGIN
ThisColor := Purple;
IF ThisColor >= Orange THEN
    BEGIN
    WRITE ('O');
    IF ThisColor = Purple THEN { THIS IS LINE 13 }
        WRITELN ('K');
    END;
END.
