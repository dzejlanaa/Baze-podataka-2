/*
Kreirati bazu podataka pod vlastitim brojem indeksa
i aktivirati je.
*/
create database ispit_24_06_2021
use ispit_24_06_2021
---------------------------------------------------------------------------
--Prilikom kreiranja tabela voditi ra�una o njihovom me�usobnom odnosu.
---------------------------------------------------------------------------
/*
a) 
Kreirati tabelu prodavac koja �e imati sljede�u strukturu:
	- prodavac_id, cjelobrojni tip, primarni klju�
	- naziv_posla, 50 unicode karaktera
	- dtm_rodj, datumski tip
	- bracni_status, 1 karakter
	- prod_kvota, nov�ani tip
	- bonus, nov�ani tip
*/

create table prodavac(
prodavac_id int,
naziv_posla nvarchar(50),
dtm_rodj date,
bracni_status nchar(1),
prod_kvota money,
bonus money,
constraint PK_prodavac primary key(prodavac_id)
);
select * from prodavac
/*
b) 
Kreirati tabelu prodavnica koja �e imati sljede�u strukturu:
	- prodavnica_id, cjelobrojni tip, primarni klju�
	- naziv_prodavnice, 50 unicode karaktera
	- prodavac_id, cjelobrojni tip
*/

create table prodavnica(
prodavnica_id int,
naziv_prodavnice nvarchar(50),
prodavac_id int,
constraint PK_prodavnica primary key(prodavnica_id),
constraint FK_prodavac_prodavnica foreign key(prodavac_id) references prodavac(prodavac_id)
);
select * from prodavnica

/*
c) 
Kreirati tabelu kupac_detalji koja �e imati sljede�u strukturu:
	- detalj_id, cjelobrojni tip, primarni klju�, automatsko punjenje sa po�etnom vrijedno��u 1 i inkrementom 1
	- kupac_id, cjelobrojni tip, primarni klju�
	- prodavnica_id, cjelobrojni tip
	- br_rac, 10 karaktera
	- dtm_narudz, datumski tip
	- kolicina, skra�eni cjelobrojni tip
	- cijena, nov�ani tip
	- popust, realni tip
*/


create table kupac_detalji
(
detalj_id int IDENTITY(1, 1),
kupac_id int,
prodavnica_id int,
br_rac varchar(10),
dtm_narudz date,
kolicina smallint,
cijena money,
popust float,
CONSTRAINT PK_prodaja PRIMARY KEY (detalj_id, kupac_id),
constraint FK_prodavnica_kupac_detalji foreign key(prodavnica_id) references prodavnica(prodavnica_id)

);



select * from kupac_detalji






--2.
/*
a)
Koriste�i tabele HumanResources.Employee i Sales.SalesPerson
baze AdventureWorks2017 zvr�iti insert podataka u 
tabelu prodavac prema sljede�em pravilu:
	- BusinessEntityID -> prodavac_id
	- JobTitle -> naziv_posla
	- BirthDate -> dtm_rodj
	- MaritalStatus -> bracni_status
	- SalesQuota -> prod_kvota
	- Bonus -> bonus
*/
insert into prodavac
select e.BusinessEntityID, JobTitle, BirthDate, MaritalStatus, SalesQuota, Bonus  
from AdventureWorks2017.HumanResources.Employee as e join AdventureWorks2017.Sales.SalesPerson as sp
on e.BusinessEntityID=sp.BusinessEntityID

select * from prodavac
/*
b)
Koriste�i tabelu Sales.Store baze AdventureWorks2017 
izvr�iti insert podataka u tabelu prodavnica 
prema sljede�em pravilu:
	- BusinessEntityID -> prodavnica_id
	- Name -> naziv_prodavnice
	- SalesPersonID -> prodavac_id
*/

insert into prodavnica
select BusinessEntityID, Name, SalesPersonID
from AdventureWorks2017.Sales.Store

select * from prodavnica
/*
b)
Koriste�i tabele Sales.Customer, Sales.SalesOrderHeader i SalesOrderDetail
baze AdventureWorks2017 izvr�iti insert podataka u tabelu kupac_detalji
prema sljede�em pravilu:
	- CustomerID -> kupac_id
	- StoreID -> prodavnica_id
	- AccountNumber -> br_rac
	- OrderDate -> dtm_narudz
	- OrderQty -> kolicina
	- UnitPrice -> cijena
	- UnitPriceDiscount -> popust
Uslov je da se ne dohvataju zapisi u kojima su 
StoreID i PersonID NULL vrijednost
*/


insert into kupac_detalji
select sc.CustomerID, StoreID, sc.AccountNumber, OrderDate, OrderQty, UnitPrice, UnitPriceDiscount 
from AdventureWorks2017.Sales.SalesOrderDetail as sod join AdventureWorks2017.Sales.SalesOrderHeader as soh
on sod.SalesOrderID=soh.SalesOrderID 
join  AdventureWorks2017.Sales.Customer as sc 
on sc.CustomerID= soh.CustomerID
where StoreID is not null and PersonID is not null

select * from kupac_detalji



--3.
/*
a)
U tabeli prodavac dodati izra�unatu kolonu god_rodj
u koju �e se smje�tati godina ro�enja prodavca.
b)
U tabeli kupac_detalji promijeniti tip podatka
kolone cijena iz nov�anog u decimalni tip oblika (8,2)
c)
U tabeli kupac_detalji dodati standardnu kolonu
lozinka tipa 20 unicode karaktera.
d) 
Kolonu lozinka popuniti tako da bude spojeno 
10 slu�ajno generisanih znakova i 
numeri�ki dio (bez vode�ih nula) iz kolone br_rac
*/


alter table prodavac
add god_rodj as YEAR(dtm_rodj)

select * from prodavac

alter table kupac_detalji
alter column cijena decimal(8,2)

alter table kupac_detalji
add lozinka nvarchar(20)

alter table kupac_detalji

update kupac_detalji
set lozinka=left(newid(),10) + right(br_rac,5)

select * from kupac_detalji

--4.
/*
Koriste�i tabele prodavnica i kupac_detalji
dati pregled sumiranih koli�ina po 
nazivu prodavnice i godini naru�ivanja.
Sortirati po nazivu prodavnice.
*/


 select naziv_prodavnice, YEAR(dtm_narudz) as godina , sum(kolicina) as kolicina
 from prodavnica as p join kupac_detalji as k
 on p.prodavnica_id=k.prodavnica_id
 group by naziv_prodavnice, YEAR(dtm_narudz)
 order by 1





--5.
/*
Kreirati pogled v_prodavac_cijena sljede�e strukture:
	- prodavac_id
	- bracni_status
	- sum_cijena
Uslov je da se u pogled dohvate samo oni zapisi u 
kojima je sumirana vrijednost ve�a od 1000000.
*/

go
create view  v_prodavac_cijena
as
select p.prodavac_id, bracni_status, SUM(cijena) as sum_cijena
from prodavac as p join prodavnica as pr
on p.prodavac_id=pr.prodavac_id join kupac_detalji as k
on pr.prodavnica_id=k.prodavnica_id
group by p.prodavac_id, bracni_status
having SUM(cijena)>1000000
go
select * from v_prodavac_cijena



--6.
/*
Koriste�i pogled v_prodavac_cijena
kreirati proceduru p_prodavac_cijena sa parametrom
bracni_status �ija je zadata (default) vrijednost M.
Uslov je da se procedurom dohvataju zapisi u kojima je 
vrijednost u koloni sum_cijena ve�a od srednje vrijednosti kolone sum_cijena.
Obavezno napisati kod za pokretanje procedure.
*/


create procedure p_prodavac_cijena
(
@bracni_status nchar(1)="M"
)
as
begin
select *
from v_prodavac_cijena
where bracni_status = @bracni_status and sum_cijena > (select avg(sum_cijena) from v_prodavac_cijena)
end

exec p_prodavac_cijena 'S'


--7.
/*
Iz tabele kupac_detalji prikazati zapise u kojima je 
vrijednost u koloni cijena jednaka 
minimalnoj, odnosno, maksimalnoj vrijednosti u ovoj koloni.
Upit treba da vra�a kolone kupac_id, prodavnica_id i cijena.
Sortirati u rastu�em redoslijedu prema koloni cijena.
*/



select kupac_id,prodavnica_id, cijena
from kupac_detalji
where cijena = (select min(cijena) from kupac_detalji)
union
select kupac_id,prodavnica_id, cijena
from kupac_detalji
where cijena = (select max(cijena) from kupac_detalji)
order by 3




