select *
  from smy_usuario
 where upper(nome) like '%DANIEL GUIMARAES%';

delete from smy_usuario_permissao
 where idusu = 2368;
commit;