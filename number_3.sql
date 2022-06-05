/* Удаление БД №3, если такая существует*/
drop database if exists number_3;
/* Создание базы данных №3*/
create database number_3;
/* Открытие базы данных*/
use number_3;

/* Очистка БД от всех таблиц */
drop table if exists `Книги`;
drop table if exists `Заказы`;
drop table if exists `Книги заказа`;

/*1. Создание таблиц*/
create table `Книги` (
`ISBN` varchar(30) not null primary key,
`ФИО автора` varchar(30) not null,
`Название книги` varchar(20) not null,
`Год издания` int not null,
`Цена` int not null
);

create table `Заказы` (
`№ заказа` int not null primary key,
`Адрес доставки` varchar(60) not null,
`Дата заказа` date not null,
`Дата выполнения заказа` date,
`Количество книг в заказе` int
);

create table `Книги заказов` (
`№ заказа` int not null,
`ISBN` varchar(30) not null,
`Количество` int not null,
foreign key (`№ заказа`) references `Заказы`(`№ заказа`) on update cascade on delete cascade,
foreign key (`ISBN`) references `Книги`(`ISBN`) on update cascade on delete cascade,
primary key(`№ заказа`,`ISBN`, `Количество`)
);

/* Заполнение таблиц*/
insert into `Книги`(`ISBN`, `ФИО автора`, `Название книги`, `Год издания`, `Цена`) 
values
('978-5-388-00003', 'Иванов Сергей Степанович', 'Самоучитель JAVA', 2018, 800),
('978-5-699-58103', 'Сидорова Ольга Юрьевна', 'JAVA за 21 день', 2019, 1100),
('758-3-004-87105', 'Петров Иван Петрович', 'Сопромат', 2019, 550),
('758-3-057-37854', 'Иванов Сергей Степанович', 'Механика', 2017, 780),
('675-3-423-00375', 'Петров Иван Петрович', 'Физика', 2018, 450);

insert into `Заказы`(`№ заказа`, `Адрес доставки`, `Дата заказа`, `Дата выполнения заказа`, `Количество книг в заказе`) 
values
(123456, 'Малая Арнаутская ул., д.9, кв.16 Иванов Игорь', '2018-09-20', '2018-09-22', 0),
(222334, 'Курчатов бульвар, д.33,кв.9 Петрова Светлана', '2018-09-21', null, 0),
(432152, 'Нахимовский проспект, д.12, кв.89 Васин Иван', '2018-09-21', '2018-09-23', 0);

insert into `Книги заказов`(`№ заказа`, `ISBN`, `Количество`)
values
(123456, '978-5-388-00003', 1),
(123456, '978-5-699-58103', 2),
(432152, '978-5-388-00003', 1),
(222334, '978-5-388-00003', 2),
(222334, '675-3-423-00375', 1);

/*2.*/
delimiter //
create function getCount(num int) returns int
deterministic
begin
	declare s int;
	set s = (select sum(`Количество`) from `Книги заказов`
	where `№ заказа` = num);
	return ifnull(s, 0);
end//
delimiter ;
/*Вызов процедуры*/
select getCount('222334');

/*3.*/
delimiter //
create procedure setCount()
begin
update `Заказы` set `Количество книг в заказе` = getCount(`№ заказа`);
end//
delimiter ;
/*Вызов процедуры*/
call setCount();
select * from `Заказы`;

/*4.*/
delimiter //
create procedure `setCursor`()
begin
declare num, s, b int default 0;
declare curs cursor for select `№ заказа`, sum(`Количество`) 
from `Книги заказов` group by `№ заказа`;
declare continue handler for not found set b = 1;
update `Заказы` set `Количество книг в заказе` = 0;
open curs;
while b = 0 do
fetch curs into num, s;
update `Заказы` set `Количество книг в заказе` = s 
where `№ заказа` = num;
end while;
close curs;
end//
delimiter ;
/*Вызов процедуры*/
call setCursor();
select * from `Заказы`;

/*5.*/
delimiter //
create trigger `Удаление заказа` after delete on `Книги заказов` for each row
begin
	update `Заказы` set `Количество книг в заказе` = 
    `Количество книг в заказе` - old.`Количество` where `№ заказа` = old.`№ заказа`;
end//
delimiter ;
/*Осуществление действия для срабатывания триггера*/
delete from `Книги заказов` 
where `№ заказа` = 432152 and `ISBN` = '978-5-388-00003' and `Количество` = 1;
/*Результат работы триггера*/
select * from `Заказы`;

/*6.*/
delimiter //
create trigger `Добавление заказа` after insert on `Книги заказов` for each row
begin
	update `Заказы` set `Количество книг в заказе` = 
    `Количество книг в заказе` + new.`Количество` where `№ заказа` = new.`№ заказа`;
end//
delimiter ;
/*Осуществление действия для срабатывания триггера*/
insert into `Книги заказов`(`№ заказа`, `ISBN`, `Количество`)
values
(432152, '978-5-388-00003', 1);
/*Результат работы триггера*/
select * from `Заказы`;

/*7.*/
delimiter //
create trigger `Обновление заказа` after update on `Книги заказов` for each row
begin
	update `Заказы` set `Количество книг в заказе` = 
    `Количество книг в заказе` - old.`Количество` where `№ заказа` = old.`№ заказа`;
	update `Заказы` set `Количество книг в заказе` = 
    `Количество книг в заказе` + new.`Количество` where `№ заказа` = new.`№ заказа`;
end//
delimiter ;
/*Осуществление действия для срабатывания триггера*/
update `Книги заказов` set `Количество` = 3 where `№ заказа` = 432152;
/*Результат работы триггера*/
select * from `Заказы`;

/*8*/
drop user if exists 'administrator'@'localhost';
create user'administrator'@'localhost' identified by '1';
drop user if exists 'director'@'localhost';
create user  'director'@'localhost' identified by '2';
drop user if exists 'worker'@'localhost';
create user 'worker'@'localhost' identified by '3';
drop user if exists 'visitor'@'localhost';
create user 'visitor'@'localhost' identified by '';

/*9*/
grant all privileges on *.* to 'administrator'@'localhost'
with grant option;
revoke create, drop on *.* from 'administrator'@'localhost';
grant create, drop on number_3 to 'administrator'@'localhost';
flush privileges;

/*10*/
grant all privileges on number_3 to 'director'@'localhost'
with grant option;
revoke create, drop, alter on number_3 from 'director'@'localhost';
flush privileges;

/*11*/
grant create, select on number_3.`Книги` to 'worker'@'localhost';
grant update(`ISBN`, `ФИО автора`, `Название книги`, `Год издания`) on number_3.`Книги` to 'worker'@'localhost';
grant create, select, update(`Дата выполнения заказа`) on number_3.`Заказы` to 'worker'@'localhost';
grant create, select, update on number_3.`Книги заказа` to 'worker'@'localhost';
flush privileges;

/*12*/
create view newView as
select КЗ.`№ заказа`, `Адрес доставки`, `Дата заказа`, 
`Дата выполнения заказа`, `Название книги`, `Год издания`, `Цена`
from `Книги заказов` as КЗ
join `Заказы` as З on КЗ.`№ заказа` = З.`№ заказа`
join `Книги` as К on КЗ.`ISBN` = К.`ISBN`;

/*13*/
grant select on number_3.newView to 'visitor'@'localhost';
flush privileges;