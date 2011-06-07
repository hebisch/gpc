module charbug interface;

export
charbug1 = (IsAlphaNum);

function IsAlphaNum (ch : char) : boolean;
  { Returns TRUE if ch is a letter: (A..Z, a..z) }
  { or a digit: (0..9)                           }
  { Returns FALSE otherwise                      }

end.

module charbug implementation;

function IsAlphaNum;
begin
 IsAlphaNum:= ch in ['A'..'Z','a'..'z','0'..'9'];
end;

end.
