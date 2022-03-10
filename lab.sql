/* Лабораторная работа №1 */
select pgc.conname as constraint_name,
       pgc.contype,
       ccu.table_name,
       ccu.column_name,
       pg_get_constraintdef(pgc.oid, true)
from pg_constraint pgc
join pg_namespace nsp on nsp.oid = pgc.connamespace
join pg_class  cls on pgc.conrelid = cls.oid
left join information_schema.constraint_column_usage ccu
          on pgc.conname = ccu.constraint_name
          and nsp.nspname = ccu.constraint_schema
where contype ='c'
-- and ccu.table_schema = 'public'
order by pgc.conname;

/* временные таблица для формирования ответа */
create temp table if not exists results(number bigserial, constraint_name text, type text, table_name text, column_name text, description text);

/* функция */
do $$
declare
    constraint_name text;
    type text;
    table_name text;
    column_name text;
    description text;
begin
    for constraint_name, type, table_name, column_name, description in select pgc.conname,
                                                                           pgc.contype,
                                                                           ccu.table_name,
                                                                           ccu.column_name,
                                                                           substring(pg_get_constraintdef(pgc.oid, true) from 'CHECK #"%#"%' for '#') from pg_constraint pgc
        join pg_namespace nsp on nsp.oid = pgc.connamespace
        join pg_class  cls on pgc.conrelid = cls.oid
        left join information_schema.constraint_column_usage ccu
                  on pgc.conname = ccu.constraint_name
                  and nsp.nspname = ccu.constraint_schema
        where contype ='c'
        -- and ccu.table_schema = 'public'
        order by pgc.conname loop
        insert into results (constraint_name, type, table_name, column_name, description)
        values (constraint_name, type, table_name, column_name, description);
    end loop;
end;
$$ language 'plpgsql';


/* Просмотр таблицы-ответа info */
select * from results;

drop table results;