{ COMPILE-CMD: regex.cmp }

{ Test of the RegEx unit... and maybe also of deeply nested
  `for' loops... :-}

program RegExTest;

uses GPC, RegEx;

var
  sr, s : TString;
  r : RegExType;
  From, p, l, pe, le, i, j : Integer;
  Extended, CaseInsensitive, NewLines, First, Last, NotBOL, NotEOL,
    A_Extended, A_CaseInsensitive, A_NewLines, ExpectMatch : Boolean;
  c : Char;
  Characters : CharSet;

{$field-widths}

procedure Error1 (const Msg : String);
begin
  WriteLn ('failed 1 ', Extended, CaseInsensitive, NewLines, First, Last, ' ', sr, ' : ', Msg);
  Halt (1)
end;

procedure Error2 (const Msg : String);
var i : Integer;
begin
  for i := Length (s) downto 1 do
    if s [i] = NewLine then
      begin
        Delete (s, i, 1);
        Insert ('\n', s, i)
      end;
  WriteLn ('failed 1 ', Extended, CaseInsensitive, NewLines, First, Last, NotBOL, NotEOL, A_Extended, A_CaseInsensitive, A_NewLines, From, ' ', sr, ' ', s, ' : ', Msg);
  Halt (1)
end;

procedure Error3 (Msg : String; const Characters : CharSet);
var
  c : Char;
  j : Integer;
begin
  Write ('failed 2 ', Extended, i);
  for c in Characters do Write (' #', Ord (c) : 1);
  if sr <> '' then
    begin
      for j := 1 to Length (sr) do
        if not IsPrintable (sr [j]) then sr [j] := '?';
      Write (' `', sr, '''')
    end;
  WriteLn (' : ', Msg);
  Halt (1)
end;

procedure TestSet (const Characters : CharSet);
begin
  for Extended := False to True do
    begin
      sr := CharSet2RegEx (Characters);
      NewRegEx (r, sr, Extended, False, False);
      if r.Error <> nil then Error3 (r.Error^, Characters);
      if MatchRegEx (r, '', False, False) then Error3 ('match empty string', Characters);
      for c := Low (c) to High (c) do
        if MatchRegEx (r, c, False, False) <> (c in Characters) then
          begin
            if c in Characters
              then WriteStr (s, '#', Ord (c) : 1, ' does not match')
              else WriteStr (s, '#', Ord (c) : 1, ' matches, but should not');
            Error3 (s, Characters)
          end;
      DisposeRegEx (r)
    end
end;

procedure TestMain;
begin
  for Extended := False to True do
    for CaseInsensitive := False to True do
      for NewLines := False to True do
        for First := False to True do
          for Last := False to True do
            begin
              sr := 'f*o((o)+)b\(a\+\)r';
              if First then Insert ('^', sr, 1);
              if Last then sr := sr + '$';
              NewRegEx (r, sr, Extended, CaseInsensitive, NewLines);
              if r.Error <> nil then Error1 (r.Error^);
              if r.SubExpressions <> 1 + Ord (Extended) then Error1 ('Number of subexpressions');
              for NotBOL := False to True do
                for NotEOL := False to True do
                  for A_Extended := False to True do
                    for A_CaseInsensitive := False to True do
                      for A_NewLines := False to True do
                        for From := 1 to 2 do
                          begin
                            if A_Extended then s := 'fooob(a+)r' else s := 'fo((o)+)bar';
                            if A_CaseInsensitive then UpCaseString (s);
                            if A_NewLines then Insert ('x' + NewLine, s, 1);
                            ExpectMatch := (Extended = A_Extended) and
                                           (CaseInsensitive or not A_CaseInsensitive) and
                                           (not First or ((not NotBOL and (From = 1) and not A_NewLines) or (NewLines and A_NewLines))) and
                                           (not Last or not NotEOL);
                            if MatchRegExFrom (r, s, NotBOL, NotEOL, From) <> ExpectMatch then
                              if ExpectMatch then
                                Error2 ('Expected match not found')
                              else
                                Error2 ('Unexpected match')
                            else if ExpectMatch then
                              begin
                                GetMatchRegEx (r, 1, p, l);
                                if p = 0 then Error2 ('Subexpression match not found');
                                if Extended then
                                  begin
                                    pe := 3;
                                    le := 2
                                  end
                                else
                                  begin
                                    pe := 10;
                                    le := 1
                                  end;
                                if A_NewLines then Inc (pe, 2);
                                if p <> pe then Error2 ('Wrong position of subexpression match');
                                if l <> le then Error2 ('Wrong length of subexpression match');
                                if Extended then
                                  begin
                                    GetMatchRegEx (r, 2, p, l);
                                    if p = 0 then Error2 ('Inner subexpression match not found');
                                    if p <> pe + le - 1 then Error2 ('Wrong position of inner subexpression match');
                                    if l <> 1 then Error2 ('Wrong length of inner subexpression match')
                                  end
                              end
                          end;
              DisposeRegEx (r)
            end;
end;

begin
  Randomize;
  TestMain;
  TestSet (SpaceCharacters);
  TestSet (DirSeparators);
  TestSet (['/']);
  TestSet ([':', '\', '/']);
  TestSet (EnvVarCharsFirst);
  TestSet (EnvVarChars);
  TestSet (['A' .. 'Z']);
  TestSet (['a' .. 'z']);
  TestSet (['A' .. 'z']);
  TestSet (['A' .. 'Z', 'a' .. 'z', '_']);
  TestSet (['A' .. 'Z', 'a' .. 'z', '_', '0' .. '9']);
  TestSet (WildCardChars);
  TestSet (FileNameSpecialChars);
  TestSet ([Low (Char) .. High (Char)]);
  TestSet (['^']);
  TestSet (['-']);
  TestSet (['^', '-']);
  TestSet (['[']);
  TestSet (['[', '^']);
  TestSet (['[', '-']);
  TestSet (['[', '^', '-']);
  TestSet ([']']);
  TestSet ([']', '^']);
  TestSet ([']', '-']);
  TestSet ([']', '^', '-']);
  TestSet ([']', '[']);
  TestSet ([']', '[', '^']);
  TestSet ([']', '[', '-']);
  TestSet ([']', '[', '^', '-']);
  for i := 0 to $100 do
    begin
      Characters := [];
      for j := 1 to i do
        begin
          repeat
            c := Chr (Random (Ord (High (c)) + 1))
          until not (c in Characters);
          Characters := Characters + [c]
        end;
      sr := '';
      if Card (Characters) <> i then Error3 ('Card1', Characters);
      if Card (Characters) <> i then Error3 ('Card2', Characters);
      TestSet (Characters)
    end;
  WriteLn ('OK')
end.
