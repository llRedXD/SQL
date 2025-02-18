select b.seqproduto,
       c.nroempresa,
       c.dtavalidade,
       c.codacesso,
       b.descreduzida,
       c.vlrpreco,
       --'' as linha1,
       '^XA^PQ'
       || 1
         --  || nvl(
         --     a.qtdetiqueta,
         --     1
         --  )
       || ',,,'
       || '^FS^LL880^FS'
       || chr(13)
       || chr(10)
       ||
       -- desta em fundo preto
-- desta em fundo preto
        '^XA^DFR:FMT1.ZPL^FS
        ^LRY
        ^FO250,50^GB350,203,195^FS
        ^LRY
        ^FO255,55^A0N,100,50^FN1^FS
        ^LRY
        ^FO272,150^A0N,100,50^FN2^FS
        ^LRN
        ^FO257,320^A0N,30,20^FN3^FS
        ^FT220,350^A0B,25,30^FH\^FN4^FS
        ^FO502,320^A0N,30,20^FN5^FS
        ^XZ

       ^XA^XFR:FMT1.ZPL^FS
       ^FN1^FDProduto proximo^FS
       ^FN2^FDao vencimento^FS
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
        '^BY2,2,38^FT230,250^BEB,,Y,N^FD'
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
        '^FT255,315^A0N,75,44^FH\^FD'
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
  from map_produto b,
       mrl_prodempvencimento c
 where c.seqproduto = b.seqproduto;