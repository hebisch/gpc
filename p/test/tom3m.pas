module charbug;

export charbug3 = (IsAlphaNum);

function IsAlphaNum (ch : char; i : integer) : boolean;

end;

function IsAlphaNum;
begin
   if i > 2 then
     IsAlphaNum:= ch in ['A'..'Z','a'..'z','0'..'9']
   else
     IsAlphaNum:= false;
end;

end.
