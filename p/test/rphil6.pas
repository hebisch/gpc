    PROGRAM Test;
    USES
        RPhil6Test1 IN 'rphil6u.pas';

    VAR
        Flags : sFlagDefs;

    BEGIN
    Flags := [IDEInterface,HighDensity];
    IF IDEInterface IN Flags THEN
        WRITE ('O');

    IF GetFlagVal IN [HighDensity,DoubleDensity] THEN
        WRITELN ('K')
    ELSE
        WRITELN ('failed');
    END.
