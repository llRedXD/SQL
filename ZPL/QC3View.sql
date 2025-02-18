-- create or replace view mrlv_etiqc3tech_validade as
select a.nroempresa,
       a.seqproduto,
       a.dtabasepreco,
       a.codacesso,
       a.qtdetiqueta,
       a.dtaprominicio,
       a.dtapromfim,
       a.codacessopadrao,
       a.embalagempadrao,
       a.padraoembvenda,
       a.precoembpadrao,
       a.multeqpembpadrao,
       a.qtdunidembpadrao,
       a.tipoetiqueta,
       a.tipopreco,
       a.desccompleta,
       a.descreduzida,
       a.qtdembalagem1,
       a.multeqpemb1,
       a.qtdunidemb1,
       a.qtdembalagem2,
       a.multeqpemb2,
       a.qtdunidemb2,
       a.qtdembalagem3,
       a.multeqpemb3,
       a.qtdunidemb3,
       a.qtdembalagem4,
       a.multeqpemb4,
       a.qtdunidemb4,
       a.qtdembalagem5,
       a.multeqpemb5,
       a.qtdunidemb5,
       a.codacesso1,
       a.codacesso2,
       a.codacesso3,
       a.codacesso4,
       a.codacesso5,
       a.preco1,
       a.preco2,
       a.preco3,
       a.preco4,
       a.preco5,
       a.precomin,
       a.precomax,
       a.embalagem1,
       a.embalagem2,
       a.embalagem3,
       a.embalagem4,
       a.embalagem5,
       a.tipocodigo,
       a.qtdembcodacesso,
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
        ^FO255,55^A0N,100,50^FN1^FS
        ^FO272,160^A0N,100,50^FN2^FS
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
          when length(a.codacesso) = 14 then
                lpad(
                   a.codacesso,
                   14,
                   0
                )
          else
             lpad(
                   a.codacesso,
                   13,
                   0
                )
       end
       || '^FS'
       || chr(13)
       || chr(10)
       ||
       -- data de validade
        '^FT255,315^A0N,80,46^FH\^FD'
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
  from mrlx_baseetiquetaprod a,
       map_produto b,
       mrl_prodempvencimento c
 where a.seqproduto = b.seqproduto
   and a.precomin = a.precomax
   and a.seqproduto = c.seqproduto
   and a.nroempresa = c.nroempresa;