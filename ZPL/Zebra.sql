select b.seqproduto,
       c.nroempresa,
       c.dtavalidade,
       c.codacesso,
       b.descreduzida,
       c.vlrpreco,
       '^XA^PQ'
       || 1
       || ',,,'
       || '^FS^LL880^FS'
       || chr(13)
       || chr(10)
       ||
       -- desta em fundo preto
        '^XA^DFR:FMT1.ZPL^FS
        ^LRY
        ^FO85,30^GB350,203,195^FS
        ^FO90,40^A0N,100,50^FN1^FS
        ^FO115,145^A0N,100,50^FN2^FS
        ^LRN
        ^FO70,310^A0N,40,20^FN3^FS
        ^FT45,325^A0B,25,30^FH\^FN4^FS
        ^FO330,310^A0N,40,20^FN5^FS
        ^XZ

       ^XA^XFR:FMT1.ZPL^FS
       ^FN1^FDProduto proximo^FS
       ^FN2^FDao Vencimento^FS
       ^FN3^FD'
       || b.descreduzida
       || '^FS
       ^FN4^FD'
       || c.seqproduto
       || '^FS
       ^FN5^FDPreco:'
       || replace(
          to_char(
             c.vlrpreco,
             '99.99'
          ),
          '.',
          ','
       )
       || '^FS'
       ||
       
       -- codigo barra
        '^BY2,2,40^FT55,225^BEB,,Y,N^FD'
       ||
       case
          when length(c.codacesso) = 14 then
                lpad(
                   c.codacesso,
                   14,
                   0
                )
          else
             lpad(
                   c.codacesso,
                   13,
                   0
                )
       end
       || '^FS'
       || chr(13)
       || chr(10)
       ||
       -- data de validade
        '^FT85,300^A0N,80,47^FH\^FD'
       || 'Validade: '
       || to_char(
          c.dtavalidade,
          'DD/MM/YY'
       )
       || '^FS'
       || chr(13)
       || chr(10)
       || chr(13)
       || chr(10)
       || '^XZ'
       || chr(13)
       || chr(10) linha
  from mrl_prodempvencimento c,
       map_produto b
 where c.seqproduto = b.seqproduto;

select *
  from mrl_prodempvencimento c,
       map_produto b
 where c.seqproduto = b.seqproduto;