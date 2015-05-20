drop table if exists foo;
drop table if exists bar;
CREATE TABLE foo (
       replaces long,
       asOf long
);
insert into foo values (0, 1);
insert into foo values (1, 3);
select one, a.name, two, b.name from foo, bar a, bar b where one = a.id and two = b.id;

