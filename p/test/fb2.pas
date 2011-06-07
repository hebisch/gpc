program FB2;

const
  MAX = 10;
  ONDM2 = 20;
  H1 = 5;

TYPE

ITEN = packed RECORD
  KEY :packed ARRAY [1..MAX] OF CHAR;
  PUNT:integer;
END;

ND = packed RECORD
  POS : integer;
  IDX : packed ARRAY [1..ONDM2] OF ITEN;
END;

VAR
  DATA : ND;

begin
DATA.IDX[H1].KEY:= 'abc';
if DATA.IDX[5].KEY = 'abc       ' then WriteLn ('OK') else WriteLn ('failed')
END.
