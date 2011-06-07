program f(input, output) ;

type
  lottery_number = 1..49 ;

var
  lotto_1       : array[lottery_number] of boolean;
  lotto_2       : packed array[lottery_number] of boolean;
  n             : integer ;

begin

  n := 3 ;

  lotto_1[n] := true ;
  lotto_2[n] := true ;
  if lotto_1[n] and lotto_2[n] then WriteLn ('OK') else WriteLn ('failed')
end .
