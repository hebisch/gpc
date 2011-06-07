{$W-}

module nick2m interface;
export nick2m=all;

procedure mt1 (str:string);
function mt2 (str:string):string;
end.

module nick2m implementation;
procedure mt1 (str:string);
begin
    writeln (str);
end;
function mt2 (str:string):string;
begin
    mt2:=str;
end;
end.
