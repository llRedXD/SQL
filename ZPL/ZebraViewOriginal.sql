create or replace view mrlv_etiqgondola_zb_validade as
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
          || nvl(
             a.qtdetiqueta,
             1
          )
          || ',,,'
          || '^FS^LL880^FS'
          || chr(13)
          || chr(10)
          ||
       -- desta em fundo preto
           '^XA^DFR:FMT1.ZPL^FS
       ^LRY
       ^FO260,30^GB350,203,195^FS
       ^FO265,40^A0N,100,50^FN1^FS
       ^ LRN
       ^FO290,145^A0N,100,50^FN2^FS
       ^ LRN
       ^FT29,79^A0B,20,19^FH\^FN3^FS
       ^ LRN
       ^FT29,135^A0B,20,19^FH\^FN4^FS
       ^XZ

       ^XA^XFR:FMT1.ZPL^FS
       ^FN1^FDProduto proximo^FS
       ^FN2^FDao vencimento^FS
       ^FN3^FD'
          || a.seqproduto
          || '^FS
       ^FN4^FDLJ: '
          || c.nroempresa
          || '^FS'
          ||
       -- codigo barra
           '^BY2,2,40^FT235,225^BEB,,Y,N^FD'
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

       /*'^FO170,350^FWB^BY2^B3N,N,50,Y,N^FD'||
       case when length(a.codacesso)=14
           then lpad(a.codacesso, 14, 0)
             else lpad(a.codacesso, 13, 0)
               end ||'^FS'|| chr(13) || chr(10) ||     --^XZ*/
       -- data de validade
           '^FT280,320^A0N,100,40^FH\^FD'
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

      /* '^XA^PQ' || nvl(a.qtdetiqueta, 1) || ',,,' || '^FS^LL880^FS' || chr(13) || chr(10) ||
       --'^FO040,024^A0N,120,055^FD' || a.descreduzida ||
       --'^FT60,65^A0N,50,36^FH\^FD'|| a.descreduzida || '^FS'||
       -- seqproduto
       '^FT29,94^A0B,20,19^FH\^FD'||a.seqproduto||'^FS' ||
       -- codigo barra
       '^FO50,200^BY2^B3N,N,60,Y,N^FD'||
       case when length(a.codacesso)=14
           then lpad(a.codacesso, 14, 0)
             else lpad(a.codacesso, 13, 0)
               end ||'^FS'|| chr(13) || chr(10) ||     --^XZ
       -- data de validade
       '^FO60,136^GB100,50,0^FS' || chr(13) || chr(10)
       --'^FT60,136^A0N,100,50^FH\^FD'||'Validade: '||to_char(c.dtavalidade,'DD/MM/YY')|| '^FS'|| chr(13) || chr(10)
       || chr(13) || chr(10) || '^XZ' || chr(13) || chr(10) linha*/
       /*
       FT: posição X,Y
       A0N,40,50: Fonte normal, heigth, width

       */
     from mrlx_baseetiquetaprod a,
          map_produto b,
          mrl_prodempvencimento c
    where a.seqproduto = b.seqproduto
      and a.precomin = a.precomax
      and a.seqproduto = c.seqproduto
      and a.nroempresa = c.nroempresa;