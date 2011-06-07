{$nonlocal-exit}
program fjf1062c(output);
type
     o = class
         procedure p1;
         procedure p2;
         procedure p3;
     end;

procedure o.p1;
    procedure q;
        procedure p1;
            procedure q;
            begin
                exit(o.p1);
                writeln('failed11');
                halt;
            end;
        begin { p }
            q;
            writeln('failed12');
            halt;
        end;
    begin { q }
        p1;
        writeln('failed13');
        halt;
    end;
begin { o.p1 }
    q;
    writeln('failed14');
end;

procedure o.p2;
var failed : boolean;
    procedure q;
        procedure p2;
            procedure q;
            begin
                exit(p2);
                writeln('failed21');
                halt;
            end;
        begin { p2 }
             q;
             writeln('failed22');
             halt;
        end;
    begin { q }
        p2;
        failed := false
    end;
begin { o.p2 }
    failed := true;
    q;
    if failed then begin
        writeln('failed23');
        halt;
    end
end;

procedure o.p3;
    procedure q;
    begin
        exit(p3);
        writeln('failed31');
        halt;
    end;
begin { o.p3 }
    q;
    writeln('failed32');
    halt;
end;

var ov : o;
begin { main routine }
    new(ov);
    ov.p1;
    ov.p2;
    ov.p3;
    writeln('OK')
end.
