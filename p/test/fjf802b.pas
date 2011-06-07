{ @@ Work-around for a problem with COFF debug info. }
{$ifdef __GO32__}
{$local W-} {$disable-debug-info} {$endlocal}
{$endif}

program fjf802b;

procedure shl;

  operator shl (a: Char; b: Integer) c: Char;
  begin
    c := Succ (a, b)
  end;

begin
  WriteLn ('O', Pred ('K' shl 5, 5))
end;

begin
  shl
end.
