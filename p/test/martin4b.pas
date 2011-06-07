program martin4b;

type
    mylupage = record
                   datadisp : packed 0..31
               end ;
    mylopage = ^mylupage;

function lichkp1( mypage : mylopage ) : integer ;
begin
    if ( mypage^.datadisp < 21 ) or ( mypage^.datadisp > 25 ) then
        lichkp1 := 100
    else
        lichkp1 := 200 ;
end ;

var
  v: integer;
  w: mylupage;

begin
  for v := 0 to 31 do
    begin
      w.datadisp := v;
      if lichkp1 (@w) <> 100 + 100 * Ord (v in [21 .. 25]) then
        begin
          WriteLn ('failed ', v);
          Halt
        end
    end;
  WriteLn ('OK')
end.
