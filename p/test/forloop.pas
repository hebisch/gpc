program ForLoop;

var
  a: Integer;
  b: Char;
  c: Boolean;
  d: (e, f, g, h, i, j, k);

begin
  for a := 1 to 3 do Write (a);
  WriteLn;
  for a := 1 to 8 do
    begin
      Write (a);
      if a = 4 then Break;
      Write (a)
    end;
  WriteLn;
  for a := 1 to 8 do
    begin
      Write (a);
      if a < 5 then Continue;
      Write (a)
    end;
  WriteLn;
  for a := 3 to 1 do Write (a);
  WriteLn;
  for a := 3 to 2 do Write (a);
  WriteLn;
  for a := 3 to 3 do Write (a);
  WriteLn;
  for a := 3 to 4 do Write (a);
  WriteLn;
  for a := 3 to 5 do Write (a);
  WriteLn;
  for b := 'A' to 'F' do Write (b);
  WriteLn;
  for c := False to True do Write (c);
  WriteLn;
  for d := g to k do Write (Ord (d));
  WriteLn;

  for a := 3 downto 1 do Write (a);
  WriteLn;
  for a := 8 downto 1 do
    begin
      Write (a);
      if a = 4 then Break;
      Write (a)
    end;
  WriteLn;
  for a := 8 downto 1 do
    begin
      Write (a);
      if a < 5 then Continue;
      Write (a)
    end;
  WriteLn;
  for a := 3 downto 1 do Write (a);
  WriteLn;
  for a := 3 downto 2 do Write (a);
  WriteLn;
  for a := 3 downto 3 do Write (a);
  WriteLn;
  for a := 3 downto 4 do Write (a);
  WriteLn;
  for a := 3 downto 5 do Write (a);
  WriteLn;
  for b := 'F' downto 'A' do Write (b);
  WriteLn;
  for c := True downto False do Write (c);
  WriteLn;
  for d := k downto g do Write (Ord (d));
  WriteLn;

  for a in [2, 3, 5, 7] do Write (a);
  WriteLn;
  for a in [2, 3, 5, 7] do
    begin
      Write (a);
      if a = 5 then Break;
      Write (a)
    end;
  WriteLn;
  for a in [2, 3, 5, 7] do
    begin
      Write (a);
      if a < 5 then Continue;
      Write (a)
    end;
  WriteLn;

  for b in ['a', 'c', 'x', 'y'] do Write (b);
  WriteLn;
  for b in ['a', 'c', 'x', 'y'] do
    begin
      Write (b);
      if b = 'x' then Break;
      Write (b)
    end;
  WriteLn;
  for b in ['a', 'c', 'x', 'y'] do
    begin
      Write (b);
      if b < 'x' then Continue;
      Write (b)
    end;
  WriteLn;

  for c in [True, False] do Write (c);
  WriteLn;
  for c in [True, False] do
    begin
      Write (c);
      if not c then Break;
      Write (c)
    end;
  WriteLn;
  for c in [True, False] do
    begin
      Write (c);
      if not c then Continue;
      Write (c)
    end;
  WriteLn;

  for d in [f, h, i, k] do Write (Ord (d));
  WriteLn;
  for d in [f, h, i, k] do
    begin
      Write (Ord (d));
      if d = i then Break;
      Write (Ord (d))
    end;
  WriteLn;
  for d in [f, h, i, k] do
    begin
      Write (Ord (d));
      if d < i then Continue;
      Write (Ord (d))
    end;
  WriteLn;

  {$local W-} for a in [] do {$endlocal} Write (a);
  WriteLn;
  {$local W-} for a in [] do {$endlocal}
    begin
      Write (a);
      if a = 5 then Break;
      Write (a)
    end;
  WriteLn;
  {$local W-} for b in [] do {$endlocal}
    begin
      Write (a);
      if a < 5 then Continue;
      Write (a)
    end;
  WriteLn;

  for a := 1 to 3 do
    for b in ['a', 'c', 'x', 'y'] do
      for c := True downto False do
        for d in [f, h, i, k] do
          Write (a, b, Ord (c), Ord (d), ' ');
  WriteLn ('.')
end.
