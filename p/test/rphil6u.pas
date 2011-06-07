    UNIT RPhil6Test1;

    INTERFACE

    TYPE
        eFlagDefs = (IDEInterface,DoubleDensity,HighDensity);
        sFlagDefs = SET OF eFlagDefs;

    FUNCTION GetFlagVal : eFlagDefs;

    IMPLEMENTATION

    FUNCTION GetFlagVal: eFlagDefs;

    BEGIN { GetFlagVal }
      GetFlagVal:= HighDensity;
    END { GetFlagVal };

    END.
