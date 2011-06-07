program dimwit3;

procedure p;

    function f :boolean;
    begin
        f := true
    end;

    procedure q;
    begin
    end;

    { Second erroneous copy.}
    procedure q; {WRONG}
    begin
        while not f do
            p
    end;

begin
end;

begin
end
.

