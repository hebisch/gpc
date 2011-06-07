module dajmod3 interface;

export
       globaltypes =(astring);
       globalvars  =(shared_data);

TYPE
      astring=string(255);

 VAR
      shared_data : record
                     prefix:astring;
                    end;

end. {of module header}

module dajmod3 implementation;

end. {of module implentation}
