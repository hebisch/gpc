module charbug interface;

export
charbug2 = (IsAlphaNum);

function IsAlphaNum (ch : char; i : integer) : boolean;

end.

module charbug implementation;

function IsAlphaNum;
begin
   if i > 2 then
     IsAlphaNum:= ch in ['A'..'Z','a'..'z','0'..'9']
   else
     IsAlphaNum:= false;
end;

end.
