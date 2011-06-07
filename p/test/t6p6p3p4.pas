{ FLAG --extended-pascal }

 program t6p6p3p4 (output);
      var globalone, globaltwo : integer;

      procedure dummy;
         begin
         writeln('fail4')
         end { of dummy };

      procedure p(procedure f(procedure ff; procedure gg); procedure g);
         var localtop : integer;

         procedure r;
            begin {r}
            if globalone = 1 then begin
               if (globaltwo <> 2) or (localtop <> 1) then
                  writeln('fail1')
               end
            else if globalone = 2 then begin
               if (globaltwo <> 2) or (localtop <> 2) then
                  writeln('fail2')
               else writeln('OK')
               end
            else writeln('fail3');
            globalone := globalone + 1
            end { of r };

         begin { of p }
         globaltwo := globaltwo + 1;
         localtop := globaltwo;
         if globaltwo = 1 then p(f, r)
         else                  f(g, r)
         end { of p };

      procedure q (procedure f; procedure g);
         begin
         f;
         g
         end { of q};

      begin { of t6p6p3p4 }
      globalone := 1;
      globaltwo := 0;
      p(q, dummy)
      end. { of t6p6p3p4 }
