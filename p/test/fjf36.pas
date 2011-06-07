Program fjf36;

{error: Typed constants being "static" fails with high optimization
        levels in combination with debugging information. :-(
        This only occurs with GCC2, not with EGCS.}

{$W-}

Procedure WriteChar;

Const
  Ch: Char = 'O';

begin { WriteChar }
  write ( Ch );
  Ch:= 'K';
end { WriteChar };

begin
  WriteChar;
  WriteChar;
  writeln;
end.
