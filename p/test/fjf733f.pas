{ NOTE: You do not want to disable basic keywords such as `type'.
  This is only a stupid example. You have been warned! }

{$disable-keyword type begin}

program fjf733f;

var
  Type: Char = 'O';
  Begin: Char = 'K';

{$enable-keyword begin}
Begin
{$disable-keyword begin}
  WriteLn (Type, Begin)
End.
