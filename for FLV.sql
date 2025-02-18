declare
   cursor c_distinct is
   select distinct seqproduto,
                   seqfornecedor,
                   qtdconferida
     from tsmy_flv_cargasaldo;

   rec_distinct       c_distinct%rowtype;
   qtdconferida_saldo number;
   qtdconferida_total number;
   total_records      number;
   record_count       number := 0;
begin
   open c_distinct;
   loop
      fetch c_distinct into rec_distinct;
      exit when c_distinct%notfound;
      qtdconferida_total := rec_distinct.qtdconferida;
      qtdconferida_saldo := rec_distinct.qtdconferida;

      -- Obter o número total de registros para o seqfornecedor atual
      select count(*)
        into total_records
        from tsmy_flv_cargasaldo
       where seqfornecedor = rec_distinct.seqfornecedor;

      

      -- Fazer uma consulta com base no seqfornecedor
      for rec in (
         select *
           from tsmy_flv_cargasaldo
          where seqfornecedor = rec_distinct.seqfornecedor
      ) loop
         record_count := record_count + 1;

         -- Mostrar o valor de qtdconferida_saldo no console
         dbms_output.put_line('qtdconferida_saldo: ' || qtdconferida_saldo);

               -- Verificar se é o último item do loop
         if record_count = total_records then
            if qtdconferida_saldo > 0 then
               update tsmy_flv_cargasaldo
                  set qtdarq = qtdconferida_saldo - qtdimportada,
                      qtdconferida = qtdconferida_saldo
                where nrocarga = rec.nrocarga;
               commit;
            end if;
            continue;
         end if;

         if qtdconferida_saldo > rec.qtdimportada then
            update tsmy_flv_cargasaldo
               set saldo = qtdconferida_saldo - rec.qtdimportada,
                   qtdarq = rec.qtdimportada,
                   qtdconferida = rec.qtdimportada
             where nrocarga = rec.nrocarga;
            qtdconferida_saldo := qtdconferida_saldo - rec.qtdimportada;
            commit;
         end if;




      end loop;

      -- Resetar o contador de registros para o próximo seqfornecedor
      record_count := 0;
   end loop;
   close c_distinct;
end;

select *
  from tsmy_flv_cargasaldo;