drop database if exists number_1;
create database number_1;
use number_1;

drop table if exists `Контроль`;
drop table if exists `Расписание`;
drop table if exists `Дисциплины`;
drop table if exists `Преподаватели`;

create table `Контроль` (
  `Номер группы` varchar(10) not null,
  `Код дисциплины` int not null check (`Код дисциплины` > 0),
  `Кол-во часов лекций` int not null check (`Кол-во часов лекций` > 0),
  `Кол-во часов семинаров` int not null check (`Кол-во часов семинаров` > 0),
  `Итоговый контроль` varchar(10) not null check (`Итоговый контроль` = "Зачёт" or `Итоговый контроль` = "Экзамен"),
  primary key(`Номер группы`, `Код дисциплины`)
);

create table `Расписание` (
  `Номер группы` varchar(10) not null,
  `Дата` date not null,
  `Номер пары` int not null check (`Номер пары` > 0),
  `Код дисциплины` int not null check (`Код дисциплины` > 0),
  primary key(`Номер группы`, `Дата`, `Номер пары`)
);

create table `Дисциплины` (
  `Код дисциплины` int not null primary key check (`Код дисциплины` > 0),
  `Название дисциплины` varchar(30) not null,
  `Код преподавателя` int not null check (`Код преподавателя` > 0)
);

create table `Преподаватели` (
  `Код преподавателя` int not null primary key check (`Код преподавателя` > 0),
  `ФИО` varchar(30) not null,
  `Должность` varchar(20) not null
);

insert into `Контроль` (`Номер группы`, `Код дисциплины`, `Кол-во часов лекций`, `Кол-во часов семинаров`, `Итоговый контроль`)
	values ("ИВТ-204", 100, 12, 20, "Зачёт"),
		    ("ИВТ-204", 101, 16, 16, "Экзамен"),
		    ("ГМУ-101", 100, 10, 16, "Экзамен"),
		    ("ГМУ-101", 101, 12, 12, "Зачёт"),
		    ("ГМУ-201", 100, 10, 16, "Экзамен"),
		    ("ГМУ-201", 101, 12, 12, "Зачёт");

insert into `Расписание` (`Номер группы`, `Дата`, `Номер пары`, `Код дисциплины`)
	values ("ИВТ-204", '2013-11-23', 1, 100),
			("ИВТ-204", '2013-11-23', 2, 101),
		    ("ГМУ-101", '2013-11-23', 2, 100),
		    ("ГМУ-101", '2013-11-23', 1, 101),
		  	("ГМУ-201", '2013-11-24', 1, 101),
		  	("ГМУ-201", '2013-11-27', 1, 101),
		    ("ГМУ-201", '2013-11-27', 3, 100);
	
insert into `Дисциплины` (`Код дисциплины`, `Название дисциплины`, `Код преподавателя`)
	values (100, "Информатика", 1003),
            (101, "Математика", 1001);
		     
insert into `Преподаватели` (`Код преподавателя`, `ФИО`, `Должность`)
	values (1001, "Иванов Сергей Степанович", "Доцент"),
		  	(1003, "Петрова Ирина Олеговна", "Профессор");
	
select Р.`Номер группы`, `Дата`, `Номер пары`, Д.`Код дисциплины`, `Название дисциплины`,
  `Кол-во часов лекций`, `Кол-во часов семинаров`, `Итоговый контроль`, 
  П.`Код преподавателя`, `ФИО`, `Должность`
from `Дисциплины` as Д
join `Преподаватели` as П
on Д.`Код преподавателя` = П.`Код преподавателя`
join `Расписание` as Р
on Д.`Код дисциплины` = Р.`Код дисциплины`
join `Контроль` as К
on Д.`Код дисциплины` = К.`Код дисциплины` and Р.`Номер группы` = К.`Номер группы`
order by `Дата`, Р.`Номер группы` desc, `Номер пары`;