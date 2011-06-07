program fjf428;

procedure Error (n : Integer);
begin
  WriteLn ('failed #', n);
  Halt
end;

{$define d}
{$UNDEF u}

begin
  {$if false} Error (1); {$endif}
  {$IF FALSE} Error (2); {$EndIf}
  {$If True} {$else} Error (3); {$endif}
  {$iF defined(d) and not defined (u)} {$Else} Error (4); {$endif}
  {$if NOT defined(D) OR defined (u)} Error (5); {$endif}
  {$if DEFINED (d) Xor Defined (U)} {$ELSE} Error (6); {$endif}
  {$if 1 shl 3} {$else} Error (7); {$endif}
  {$if 7 SHR 4} Error (8); {$ENDIF}
  {$if defined (d) == defined (u)} Error (9); {$ENDIF}
  {$if defined (d) <> defined (u)} {$else} Error (9); {$ENDIF}
  WriteLn ('OK')
end.
