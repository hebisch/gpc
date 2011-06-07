{ Bug: IsDST was always True. This test only checks that two time
  values about half a year apart are not both in DST (which should
  hold for any time zone I hope). It doesn't do any thorough checks. }

program fjf580;

uses GPC;

function IsDST (Time: UnixTimeType) = Res: Boolean;
begin
  UnixTimeToTime (Time, null, null, null, null, null, null, null, Res, null, null)
end;

begin
  if IsDST (0) and IsDST (180 * 86400) then WriteLn ('failed') else WriteLn ('OK')
end.
