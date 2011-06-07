{$W-}

program fjf873;

begin

  { In GPC's default, these comparisons don't do padding (unlike EP). }
  if '2 ' = '2' then WriteLn ('failed 1') else
  if not ('2 ' <> '2') then WriteLn ('failed 2') else
  if '2 ' <= '2' then WriteLn ('failed 3') else
  if not ('2 ' > '2') then WriteLn ('failed 4') else
  if '2' >= '2 ' then WriteLn ('failed 5') else
  if not ('2' < '2 ') then WriteLn ('failed 6') else

  { Therefore GPC provides these functions. }
  if not EQPad ('2 ', '2') then WriteLn ('failed 7') else
  if NEPad ('2 ', '2') then WriteLn ('failed 8') else
  if not LEPad ('2 ', '2') then WriteLn ('failed 9') else
  if GTPad ('2 ', '2') then WriteLn ('failed 10') else
  if not GEPad ('2', '2 ') then WriteLn ('failed 11') else
  if LTPad ('2', '2 ') then WriteLn ('failed 12') else

  WriteLn ('OK')

end.
