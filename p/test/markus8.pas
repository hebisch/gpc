program Markus8;

type
  pProe = Pointer;

  tPruzzel = object
    Procedure amazooka ( proe: pProe );
  end (* tPruzzel *);

Procedure tPruzzel.amazooka ( p: pProe );  { WRONG }

begin (* tPruzzel.amazooka *)
end (* tPruzzel.amazooka *);

begin
end.
