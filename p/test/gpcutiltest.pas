{ Test of the GPCUtil unit }

program GPCUtilTest;

uses GPCUtil;

var
  i : Integer;
  l : LongInt;
  r : Real;
  s1, s2 : String (100);

procedure Error (const Msg : String);
begin
  WriteLn ('Error in ', Msg);
  Halt (1)
end;

begin
  if ForceExtension ('foo.bar', '.qux') <> 'foo.qux' then Error ('ForceExtension');
  if PadCh ('foo', 'x', 7) <> 'fooxxxx' then Error ('PadCh');
  if LeftPadCh ('foo', 'x', 7) <> 'xxxxfoo' then Error ('LeftPadCh');
  if CString2String (Int2PChar (3)) <> '3' then Error ('Int2PChar');
  if Int2Str (42) <> '42' then Error ('Int2Str');
  if Str2Int ('7x', i) then Error ('Str2Int #1');
  if not Str2Int ('7', i) or_else (i <> 7) then Error ('Str2Int #2');
  if Str2Long ('42x', l) then Error ('Str2Real #1');
  if not Str2Long ('42', l) or_else (l <> 42) then Error ('Str2Long #2');
  if Str2Real ('5.6e', r) then Error ('Str2Real #1');
  if not Str2Real ('5.6e2', r) or_else (r <> 560) then Error ('Str2Real #2');
  if BreakStr ('foobar', s1, s2, ' ') then Error ('BreakStr #1');
  if not BreakStr ('foo bar', s1, s2, ' ') or_else (s1 <> 'foo') or_else (s2 <> 'bar') then Error ('BreakStr #2');
  if ReplaceChar ('foo', 'o', 'u') <> 'fuu' then Error ('ReplaceChar');
  WriteLn ('OK')
end.
