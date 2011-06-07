module dajmod2 interface;

export
       progtypes   =(TPROGTYPE, prog_none..prog_last);
       globalvars  =(pgmtype);

TYPE
      TPROGTYPE=(prog_none, prog_press,
                 prog_last);

 VAR
      pgmtype:TPROGTYPE;

end. {of module header}

module dajmod2 implementation;

end. {of module implentation}
