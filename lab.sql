/* Лабораторная работа №1 */

/* временные таблица для формирования ответа */
create temp table if not exists results(number bigserial, sc text, constraint_name text, type text, table_name text, column_name text, description text);
create temp table if not exists params(schemes text);
insert into params values (:v1);

/* Анонимный блок */
do $$
declare
    constraint_name text;
    type text;
    sc text;
    table_name text;
    column_name text;
    description text;
begin
    for sc, constraint_name, type, table_name, column_name, description in select nsp.nspname,
                                                                            pgc.conname,
                                                                           pgc.contype,
                                                                           cls.relname,
                                                                           cls.relname,
                                                                           substring(pg_get_constraintdef(pgc.oid, true) from 'CHECK #"%#"%' for '#') from pg_constraint pgc
        join pg_namespace nsp on nsp.oid = pgc.connamespace
        join pg_class cls on pgc.conrelid = cls.oid

--         left join information_schema.constraint_column_usage ccu
--                   on pgc.conname = ccu.constraint_name
--                   and nsp.nspname = ccu.constraint_schema
        where contype ='c'
        and (select count(schemes) from params where schemes = nsp.nspname) > 0
        order by pgc.conname
    loop
        insert into results (constraint_name, sc, type, table_name, column_name, description)
        values (constraint_name, sc, type, table_name, column_name, description);
    end loop;
end
$$ language 'plpgsql';

/* Просмотр таблицы-ответа info */
select * from params;
select * from results;

-- select * from params where (select schemes from params where schemes = 'public') is not null;

drop table results;
drop table params;
