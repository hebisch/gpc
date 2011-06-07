program mir048f;
{Integer2StringBaseExt(), checking UpperCase parameter}
uses GPC;
var i : LongInt;
    ec, Base, Width: Integer;
    s : String (4096);

begin
  Base := 16;
  Width := 0;
  s := Integer2StringBaseExt ($fffff, Base, Width, True, False);
  if s <> 'FFFFF' then
    WriteLn ('failed: ', s)
  else
    begin
      Base := 36;
      Val ('36#JERUSALEM', i, ec);
      if ((Integer2StringBaseExt (i, Base, Width, True, False) = 'JERUSALEM') and
          (Integer2StringBaseExt (i, Base, Width, False, False) = 'jerusalem')) then
        WriteLn ('OK')
      else
        WriteLn ('failed')
    end
end.
