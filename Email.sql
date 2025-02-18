declare
-- Variáveis
   vnqtdeitens       number := 0;
   obj_param_smtp    c5_tp_param_smtp;
   vscabec           varchar2(5000);
   vscabectabela     varchar2(5000);
   vsmensagem        clob;
   vsdepartamentoant varchar2(4000) := ' ';
   cursor c_oper is
   select nroempresa,
          departamento,
          id_mov,
          nomerazao,
          seqproduto,
          decode(
             interno,
             null,
             0,
             interno
          ) as interno,
          desccompleta,
          case
             when embalagem = 'KG' then
                sum(qtd) / 1000
             else
                sum(qtd)
          end as "QTD",
          embalagem,
          codbarras,
          motivo,
          cgo,
          operacao
     from (
      select m.nroempresa,
             m.departamento,
             mi.id_mov,
             mi.id_item,
             gp.nomerazao,
             mi.seqproduto,
             (
                select pc.codacesso
                  from map_prodcodigo pc
                 where pc.tipcodigo = 'B'
                   and pc.seqproduto = mi.seqproduto
                   and pc.indutilvenda = 'S'
             ) as "INTERNO",
             p.desccompleta,
             mi.qtd,
             custo.embalagem,
             decode(
                custo.embalagem,
                       /*'UN',
                       MI.CODACESSO,*/
                'KG',
                substr(
                   (mi.codacesso),
                   2,
                   4
                ),
                mi.codacesso
             ) as "CODBARRAS",
             mt.descricao as "MOTIVO",
             case
                when r.cgo = 0
                   and m.departamento <> 'PADARIA' then
                   mi.cgo
                when r.cgo = 303 then
                   mi.cgo
                else
                   r.cgo
             end as "CGO",
            -- INICIA INFORMANDO A OPERAÇÃO APLICADA AO CGO DA MOVIMENTAÇÃO,       
            -- CASO CGO DA MOVIMENTAÇÃO SEJA 0 OU 303, SUBSTITUI PELO NRO DA OPERAÇÃO NA TABELA SMY_MOVIMENTACAO_ITENS,
            -- CASO O NRO DA OPERAÇÃO FOR DIFERENTE DE 1 OU 2, SUBSTITUI PELO NRO DO CGO  NA TABELA SMY_MOVIMENTACAO_ITENS,   
             decode(
                (case
                   when r.cgo in(0,
                                 303) then
                      mi.operacao
                   when mi.operacao = 0 then
                      mi.cgo
                   else r.cgo
                end),
                '301',
                'GUARDAR',
                '705',
                'JOGAR FORA',
                '707',
                'JOGAR FORA',
                '1',
                'GUARDAR',
                '2',
                'JOGAR FORA',
                '3',
                'DEVOLUCAO CD',
                decode(
                   mi.cgo,
                   '301',
                   'GUARDAR',
                   '705',
                   'JOGAR FORA',
                   '707',
                   'JOGAR FORA'
                )
             ) as "OPERACAO"
        from smy_movimentacao_itens mi
        join smy_movimentacao m
      on mi.id_mov = m.id_mov
        join smy_motivos mt
      on m.cgo = mt.idmotivo
        join maxv_mgmbaseprodseg custo
      on mi.seqproduto = custo.seqproduto
         and custo.nroempresa = m.nroempresa
        left join map_produto p
      on mi.seqproduto = p.seqproduto
        join smy_setores s
      on m.departamento = s.descricao
        join smy_rel_setor_motivo r
      on m.cgo = r.idmotivo
         and m.departamento = s.descricao
         and s.idsetor = r.idsetor
        join map_famfornec f
      on f.seqfamilia = p.seqfamilia
        join ge_pessoa gp
      on gp.seqpessoa = f.seqfornecedor
        join map_famdivcateg d
      on d.seqfamilia = p.seqfamilia
        join map_categoria c
      on c.seqcategoria = d.seqcategoria
       where custo.nrosegmento = 1
         and trunc(m.dtamovimentacao) = trunc(to_date('2024-11-24',
      'yyyy-mm-dd'))
         and trunc(m.dtageracaotxt) is not null
         and m.nroempresa = 3
         and custo.qtdembalagem = 1
         and c.seqcategoria not in ( 1,
                                     3,
                                     5,
                                     7,
                                     9,
                                     32,
                                     682,
                                     652,
                                     670,
                                     689,
                                     692,
                                     21 ) -- verificar seq na tabela map_categoria               
         and f.principal = 'S'
       group by m.nroempresa,
                m.departamento,
                mi.id_mov,
                mi.id_item,
                gp.nomerazao,
                mi.seqproduto,
                p.desccompleta,
                mi.qtd,
                custo.embalagem,
                mi.codacesso,
                mt.descricao,
                case
                   when r.cgo = 0
                      and m.departamento <> 'PADARIA' then
                      mi.cgo
                   when r.cgo = 303 then
                      mi.cgo
                   else
                      r.cgo
                end,
                decode(
                   (case
                      when r.cgo in(0,
                                    303) then
                         mi.operacao
                      when mi.operacao = 0 then
                         mi.cgo
                      else r.cgo
                   end),
                   '301',
                   'GUARDAR',
                   '705',
                   'JOGAR FORA',
                   '707',
                   'JOGAR FORA',
                   '1',
                   'GUARDAR',
                   '2',
                   'JOGAR FORA',
                   '3',
                   'DEVOLUCAO CD',
                   decode(
                      mi.cgo,
                      '301',
                      'GUARDAR',
                      '705',
                      'JOGAR FORA',
                      '707',
                      'JOGAR FORA'
                   )
                )
       order by m.departamento,
                mi.id_mov,
                p.desccompleta
   )
    where cgo <> 0
      and departamento = 'HORTI'
    group by nroempresa,
             departamento,
             id_mov,
             nomerazao,
             seqproduto,
             interno,
             desccompleta,
             embalagem,
             codbarras,
             motivo,
             cgo,
             operacao
    order by departamento,
             operacao,
             nomerazao;

begin
   INSERT INTO smy_log_email_movimentacao_lj select nroempresa,
          departamento,
          id_mov,
          nomerazao,
          seqproduto,
          decode(
             interno,
             null,
             0,
             interno
          ) as interno,
          desccompleta,
          case
             when embalagem = 'KG' then
                sum(qtd) / 1000
             else
                sum(qtd)
          end as "QTD",
          embalagem,
          codbarras,
          motivo,
          cgo,
          operacao
     from (
      select m.nroempresa,
             m.departamento,
             mi.id_mov,
             mi.id_item,
             gp.nomerazao,
             mi.seqproduto,
             (
                select pc.codacesso
                  from map_prodcodigo pc
                 where pc.tipcodigo = 'B'
                   and pc.seqproduto = mi.seqproduto
                   and pc.indutilvenda = 'S'
             ) as "INTERNO",
             p.desccompleta,
             mi.qtd,
             custo.embalagem,
             decode(
                custo.embalagem,
                       /*'UN',
                       MI.CODACESSO,*/
                'KG',
                substr(
                   (mi.codacesso),
                   2,
                   4
                ),
                mi.codacesso
             ) as "CODBARRAS",
             mt.descricao as "MOTIVO",
             case
                when r.cgo = 0
                   and m.departamento <> 'PADARIA' then
                   mi.cgo
                when r.cgo = 303 then
                   mi.cgo
                else
                   r.cgo
             end as "CGO",
            -- INICIA INFORMANDO A OPERAÇÃO APLICADA AO CGO DA MOVIMENTAÇÃO,       
            -- CASO CGO DA MOVIMENTAÇÃO SEJA 0 OU 303, SUBSTITUI PELO NRO DA OPERAÇÃO NA TABELA SMY_MOVIMENTACAO_ITENS,
            -- CASO O NRO DA OPERAÇÃO FOR DIFERENTE DE 1 OU 2, SUBSTITUI PELO NRO DO CGO  NA TABELA SMY_MOVIMENTACAO_ITENS,   
             decode(
                (case
                   when r.cgo in(0,
                                 303) then
                      mi.operacao
                   when mi.operacao = 0 then
                      mi.cgo
                   else r.cgo
                end),
                '301',
                'GUARDAR',
                '705',
                'JOGAR FORA',
                '707',
                'JOGAR FORA',
                '1',
                'GUARDAR',
                '2',
                'JOGAR FORA',
                '3',
                'DEVOLUCAO CD',
                decode(
                   mi.cgo,
                   '301',
                   'GUARDAR',
                   '705',
                   'JOGAR FORA',
                   '707',
                   'JOGAR FORA'
                )
             ) as "OPERACAO"
        from smy_movimentacao_itens mi
        join smy_movimentacao m
      on mi.id_mov = m.id_mov
        join smy_motivos mt
      on m.cgo = mt.idmotivo
        join maxv_mgmbaseprodseg custo
      on mi.seqproduto = custo.seqproduto
         and custo.nroempresa = m.nroempresa
        left join map_produto p
      on mi.seqproduto = p.seqproduto
        join smy_setores s
      on m.departamento = s.descricao
        join smy_rel_setor_motivo r
      on m.cgo = r.idmotivo
         and m.departamento = s.descricao
         and s.idsetor = r.idsetor
        join map_famfornec f
      on f.seqfamilia = p.seqfamilia
        join ge_pessoa gp
      on gp.seqpessoa = f.seqfornecedor
        join map_famdivcateg d
      on d.seqfamilia = p.seqfamilia
        join map_categoria c
      on c.seqcategoria = d.seqcategoria
       where custo.nrosegmento = 1
         and trunc(m.dtamovimentacao) = trunc(to_date('2024-11-24',
      'yyyy-mm-dd'))
         and trunc(m.dtageracaotxt) is not null
         and m.nroempresa = 3
         and custo.qtdembalagem = 1
         and c.seqcategoria not in ( 1,
                                     3,
                                     5,
                                     7,
                                     9,
                                     32,
                                     682,
                                     652,
                                     670,
                                     689,
                                     692,
                                     21 ) -- verificar seq na tabela map_categoria               
         and f.principal = 'S'
       group by m.nroempresa,
                m.departamento,
                mi.id_mov,
                mi.id_item,
                gp.nomerazao,
                mi.seqproduto,
                p.desccompleta,
                mi.qtd,
                custo.embalagem,
                mi.codacesso,
                mt.descricao,
                case
                   when r.cgo = 0
                      and m.departamento <> 'PADARIA' then
                      mi.cgo
                   when r.cgo = 303 then
                      mi.cgo
                   else
                      r.cgo
                end,
                decode(
                   (case
                      when r.cgo in(0,
                                    303) then
                         mi.operacao
                      when mi.operacao = 0 then
                         mi.cgo
                      else r.cgo
                   end),
                   '301',
                   'GUARDAR',
                   '705',
                   'JOGAR FORA',
                   '707',
                   'JOGAR FORA',
                   '1',
                   'GUARDAR',
                   '2',
                   'JOGAR FORA',
                   '3',
                   'DEVOLUCAO CD',
                   decode(
                      mi.cgo,
                      '301',
                      'GUARDAR',
                      '705',
                      'JOGAR FORA',
                      '707',
                      'JOGAR FORA'
                   )
                )
       order by m.departamento,
                mi.id_mov,
                p.desccompleta
   )
    where cgo <> 0
      and departamento = 'HORTI'
    group by nroempresa,
             departamento,
             id_mov,
             nomerazao,
             seqproduto,
             interno,
             desccompleta,
             embalagem,
             codbarras,
             motivo,
             cgo,
             operacao
    order by departamento,
             operacao,
             nomerazao;
   execute immediate 'alter session set nls_numeric_characters = '',.''';

  -- Monta o Cabeçalho do HTML
   vscabec := '
              <head>
                <meta charset="utf-8" />
                <style>
                    .break { 
                    page-break-before: always;
                    }
                
                    .titulo{
                    width:100%;
                    hegth:20px;
                    border: 1px solid #000;
                    text-align: center;
                    padding:5px;
                    }    
                
                    .texto_cabec {
                        font-family: Verdana;
                        font-weight: bold;
                        color: #336699;
                        font-size: 10px;
                        background-color: #dceded;
                    }
                    
                    .texto_direita {
                    text-align: right;
                    }

                    .texto_normal {
                        font-family: Verdana;
                        font-weight:normal;
                        color: #000000;
                        font-size: 12px;
                        background-color: #ffffff;
                    }

                    .texto_item {
                        font-family: Verdana;
                        font-weight:normal;
                        color: #000000;
                        font-size: 10px;
                        background-color: #ffffff;
                    }

                    .texto_negrito {
                        font-family: Verdana;
                        font-weight: bold;
                        color: #000000;
                        font-size: 14px;
                        background-color: #ffffff;
                    }

                </style>
            </head>
            <body>
               <span class="texto_normal">'
              || 'teste 12'
              || ', <br/><br/>Abaixo encontra-se listados os produtos com suas devidas operações, movimentos de '
              || to_char(
      (trunc(to_date('2024-11-24',
      'yyyy-mm-dd'))),
      'dd " de " FMMONTH " de " YYYY',
      'nls_date_language=portuguese'
   )
              || '. <br/><br/>
        
         <div class="titulo"><h4>Loja '
              || 3
              || '</h4></div>';

   vscabectabela := '     
 
        <table border="1" style="border-collapse:collapse;" width="100%">
        <tr  class="texto_cabec">
            <td  align="center" colspan="7" >
                 Itens                
            </td>
        </tr>
        <tr class="texto_cabec">
            <td>Fornecedor</td>
            <td class="texto_direita">Seq. Produto</td>
            <td>Descrição</td>
            <td>EAN / Balança</td>
            <td>Motivo</td>
            <td class="texto_direita">Quantidade</td>
            <td>Operação</td>   

        </tr>';
   for m_i in c_oper loop
      declare
         vitem      varchar2(6000) := '';
         vqtdrecalc number := 0;
      begin
         if vsdepartamentoant <> m_i.departamento then
            if vnqtdeitens > 0 then
               vitem := '</table>';
            end if;
            vitem := vitem
                     || '<br/><span class="texto_negrito">Departamento: '
                     || m_i.departamento
                     || '</span><br/>';
            vitem := vitem || vscabectabela;
         end if;

         vnqtdeitens := vnqtdeitens + 1;
         vitem := vitem
                  || '
          <tr class="texto_item">
            

           <td>'
                  || m_i.nomerazao
                  || '</td>
            <td class="texto_direita">'
                  || m_i.seqproduto
                  || '</td>
	          <td>'
                  || m_i.desccompleta
                  || '</td>
            <td>'
                  || m_i.codbarras
                  || '</td>
            <td>'
                  || m_i.motivo
                  || '</td>'
                  ||
            case
               when m_i.embalagem = 'KG' then
                  '<td class="texto_direita">'
                  || to_char(
                     m_i.qtd,
                     '9G999G990D999'
                  )
                  || '</td>'
               else '<td class="texto_direita">'
                    || to_char(m_i.qtd)
                    || '</td>'
            end
                  || '<td>'
                  || m_i.operacao
                  || '</td>
  

        </tr>';

         vsmensagem := vsmensagem || vitem;
         vsdepartamentoant := m_i.departamento;
      end;
   end loop;
   

   vsmensagem := vscabec
                 || vsmensagem
                 || '</table>';
   vsmensagem := vsmensagem || '</table>
   
                                <br/><br/><span class="texto_normal">E-MAIL AUTOMÁTICO FAVOR NÃO RESPONDER</span>
                                </body>
                                </html>';

   

   if vnqtdeitens > 0 then
      obj_param_smtp := c5_tp_param_smtp(1);
      obj_param_smtp.emailremetente := 'nfe@yamauchi.com.br';
      obj_param_smtp.nomeremetente := 'Info - Yamauchi';
   else
      obj_param_smtp := c5_tp_param_smtp(1);
      obj_param_smtp.emailremetente := 'nfe@yamauchi.com.br';
      obj_param_smtp.nomeremetente := 'Info - Yamauchi';
   end if;

   dbms_output.put_line(vsmensagem);
end;