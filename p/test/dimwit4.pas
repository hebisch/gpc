program dimwit4(output);
type ta = packed array [1..10] of char;

procedure p;
    label 11;

    var ia : ta;

    procedure q;
    begin
        writeln('OK')
    end;

    procedure r (a: ta; x:integer);
    begin
        if ia = a then begin
            case x of
                10: q;
            end;
            goto 11;
        end;
    end;

begin
    ia := 'PR        ';
    r('PR        ',10);
11:
end;

begin
    p
end
.
