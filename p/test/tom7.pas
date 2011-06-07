{$classic-pascal}

program gpcbug2005jan27({namebook, namelist, } output);
(*
   Dr. Thomas D. Schneider
   National Cancer Institute
   Laboratory of Experimental and Computational Biology
   Molecular Information Theory Group
   Frederick, Maryland  21702-1201
   toms@ncifcrf.gov
   permanent email: toms@alum.mit.edu (use only if first address fails)
   http://www.lecb.ncifcrf.gov/~toms/

   modified by Maurice Lombardi and Frank Heckenbach
*)
const
version = 1.00; (* of gpcbug2005jan27.p 2005 jan 27 *)

var
    namebook{, namelist}: text;

begin
   rewrite(namebook);
   {close(namebook);}

   reset(namebook);
   if eof(namebook)
   then writeln(output,'OK')
   else writeln(output,'NOT eof of namebook');

{
   rewrite(namelist);
   close(namelist);

   reset(namelist);
   if eof(namelist)
   then writeln(output,'eof of namelist')
   else writeln(output,'NOT eof of namelist');
}
end.
