select *
  from tsmy_eu_ficha_colab
 where id_ficha = 7134;


select owner,
       constraint_name,
       table_name,
       constraint_type,
       column_name
  from all_constraints
 where constraint_name = 'TSMY_EU_A_ID_FICHA_96B8B6CE_F';

select owner,
       table_name,
       column_name
  from all_cons_columns
 where constraint_name = 'TSMY_EU_A_ID_FICHA_96B8B6CE_F';