CREATE USER 'ssbd06admin'@'payara' IDENTIFIED BY '123';
CREATE USER 'ssbd06glassfish'@'payara' IDENTIFIED BY '123';
CREATE USER 'ssbd06mok'@'payara' IDENTIFIED BY '123';
CREATE USER 'ssbd06mop'@'payara' IDENTIFIED BY '123';
CREATE USER 'ssbd06'@'payara' IDENTIFIED BY '123';

CREATE DATABASE IF NOT EXISTS ssbd06 ;

GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06'@'payara' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06glassfish'@'payara' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06mok'@'payara' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06admin'@'payara'WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06mop'@'payara' WITH GRANT OPTION;

CREATE USER 'ssbd06admin'@'%' IDENTIFIED BY '123';
CREATE USER 'ssbd06glassfish'@'%' IDENTIFIED BY '123';
CREATE USER 'ssbd06mok'@'%' IDENTIFIED BY '123';
CREATE USER 'ssbd06mop'@'%' IDENTIFIED BY '123';
CREATE USER 'ssbd06'@'%' IDENTIFIED BY '123';

GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06glassfish'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06mok'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06admin'@'%'WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ssbd06.* TO 'ssbd06mop'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;


USE ssbd06;

CREATE TABLE konto(id BIGINT PRIMARY KEY AUTO_INCREMENT, login VARCHAR(64) NOT NULL, CONSTRAINT unique_login UNIQUE(login), haslo CHAR(64)
NOT NULL,aktywne boolean NOT NULL DEFAULT true, potwierdzone boolean NOT NULL DEFAULT false, data_wygasniecia_tokenu TIMESTAMP
NOT NULL default CURRENT_TIMESTAMP, email_token varchar(64) NOT NULL default '', wersja BIGINT NOT NULL);

CREATE TABLE dane_osobowe (id BIGINT PRIMARY KEY AUTO_INCREMENT, FOREIGN KEY(id) REFERENCES konto(id), imie VARCHAR(20) NOT NULL, nazwisko
VARCHAR(20) NOT NULL);

CREATE TABLE poziom_dostepu (id BIGINT PRIMARY KEY AUTO_INCREMENT, poziom VARCHAR(20) NOT NULL, konto_id BIGINT, FOREIGN KEY(konto_id)
REFERENCES konto(id), CONSTRAINT unique_konto_poziom UNIQUE(konto_id,poziom), aktywny boolean NOT NULL DEFAULT true, constraint
check_poziom check(poziom in('KLIENT','WLASCICIEL_PUBU','ADMINISTRATOR')), wersja BIGINT NOT NULL);
CREATE INDEX poziom_dostepu_fkey ON poziom_dostepu(konto_id);

CREATE TABLE administrator (id BIGINT PRIMARY KEY AUTO_INCREMENT, FOREIGN KEY(id) REFERENCES poziom_dostepu(id), nr_telefonu CHAR(9) NOT NULL);

CREATE TABLE klient ( id BIGINT PRIMARY KEY AUTO_INCREMENT, FOREIGN KEY(id) REFERENCES poziom_dostepu(id), ksywka varchar(20) NOT NULL);

CREATE TABLE wlasciciel_pubu (id BIGINT PRIMARY KEY AUTO_INCREMENT, FOREIGN KEY(id) REFERENCES poziom_dostepu(id), lata_doswiadczenia BIGINT NOT
NULL, constraint check_lata check(lata_doswiadczenia > 0));

CREATE TABLE pub (id BIGINT PRIMARY KEY AUTO_INCREMENT, wlasciciel_id BIGINT NOT NULL, FOREIGN KEY(wlasciciel_id) REFERENCES wlasciciel_pubu(id),
nazwa VARCHAR(20) NOT NULL, CONSTRAINT unique_nazwa UNIQUE(nazwa), srednia_ocena double precision NOT NULL,godzina_otwarcia time NOT NULL, godzina_zamkniecia time NOT NULL,
ostateczna_godzina_rezerwacji time NOT NULL, aktywny boolean NOT NULL DEFAULT true, wersja BIGINT NOT NULL, CONSTRAINT
ostateczna_godzina_check CHECK( (godzina_otwarcia < godzina_zamkniecia AND godzina_otwarcia < ostateczna_godzina_rezerwacji AND
ostateczna_godzina_rezerwacji < godzina_zamkniecia) OR ( godzina_otwarcia > godzina_zamkniecia AND ( godzina_otwarcia <
ostateczna_godzina_rezerwacji OR godzina_zamkniecia > ostateczna_godzina_rezerwacji))), CONSTRAINT diffrent_hours CHECK(godzina_otwarcia !=
godzina_zamkniecia));
CREATE INDEX pub_fkey ON pub(wlasciciel_id);

CREATE TABLE stolik ( id BIGINT PRIMARY KEY AUTO_INCREMENT, pub_id BIGINT NOT NULL, FOREIGN KEY(pub_id) REFERENCES pub(id), ilosc_miejsc
INTEGER NOT NULL, constraint check_miejsca check(ilosc_miejsc > 0), aktywny boolean NOT NULL DEFAULT true, wersja BIGINT NOT NULL);
CREATE INDEX stolik_fkey ON stolik(pub_id);

CREATE TABLE status (id BIGINT PRIMARY KEY AUTO_INCREMENT, nazwa VARCHAR(20) NOT NULL, constraint check_nazwa check (nazwa in
('ROZPOCZETA','ZAKONCZONA','ANULOWANA')), wersja BIGINT NOT NULL);

CREATE TABLE rezerwacja (id BIGINT PRIMARY KEY AUTO_INCREMENT, klient_id BIGINT NOT NULL, FOREIGN KEY(klient_id) REFERENCES klient(id), stolik_id
BIGINT NOT NULL, FOREIGN KEY(stolik_id) REFERENCES stolik(id), status_id BIGINT NOT NULL, FOREIGN KEY(status_id) REFERENCES status
(id), data_rezerwacji Timestamp NOT NULL, wersja BIGINT NOT NULL);
CREATE INDEX rezerwacja_klient_fkey ON rezerwacja (klient_id);
CREATE INDEX rezerwacja_status_fkey ON rezerwacja (status_id);
CREATE INDEX rezerwacja_stolik_fkey ON rezerwacja (stolik_id);


CREATE TABLE ocena (id BIGINT PRIMARY KEY AUTO_INCREMENT, pub_id BIGINT NOT NULL, FOREIGN KEY(pub_id) REFERENCES pub(id), klient_id BIGINT
NOT NULL, FOREIGN KEY(klient_id) REFERENCES klient(id), ocena integer NOT NULL, CONSTRAINT unique_pub_klient_id unique(pub_id, klient_id), wersja BIGINT NOT NULL);
CREATE INDEX ocena_klient_fkey ON ocena(klient_id);
CREATE INDEX ocena_pub_fkey ON ocena(pub_id);

CREATE TABLE wydarzenie(id BIGINT PRIMARY KEY AUTO_INCREMENT, pub_id BIGINT NOT NULL, FOREIGN KEY(pub_id) REFERENCES pub(id), data_rozpoczecia
Timestamp NOT NULL, nazwa VARCHAR(20) NOT NULL, opis VARCHAR(1024) NOT NULL, wersja BIGINT NOT NULL);
CREATE INDEX wydarzenie_fkey ON wydarzenie(pub_id);


CREATE TABLE wydarzenie_z_uczestnikami(id BIGINT PRIMARY KEY AUTO_INCREMENT, wydarzenie_id BIGINT NOT NULL, uczestnik_id BIGINT NOT NULL,
FOREIGN KEY(wydarzenie_id) REFERENCES wydarzenie(id), FOREIGN KEY(uczestnik_id) REFERENCES klient(id), CONSTRAINT
unique_uczestnik_wydarzenie_id unique(uczestnik_id,wydarzenie_id));
CREATE INDEX wydarzenie_z_uczestnikami_uczestnik_fkey ON wydarzenie_z_uczestnikami(uczestnik_id);
CREATE INDEX wydarzenie_z_uczestnikami_wydarzenie_fkey ON wydarzenie_z_uczestnikami(wydarzenie_id);

CREATE VIEW glassfish_auth_view AS SELECT konto.login, konto.haslo, pd.poziom
FROM poziom_dostepu AS pd
JOIN konto ON pd.konto_id = konto.id
WHERE konto.potwierdzone = true AND konto.aktywne = true AND pd.aktywny = true;

insert into konto(id, login, haslo, aktywne,potwierdzone, wersja) values (1 , 'admin@edu.pl', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', true, true, 1);
insert into konto(id, login, haslo, aktywne,potwierdzone, wersja) values (2 , 'klient@edu.pl', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f' , true, true, 1);
insert into konto(id, login, haslo, aktywne,potwierdzone, wersja) values (3 , 'wlasciciel@edu.pl', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', true, true, 1);
insert into konto(id, login, haslo, aktywne,potwierdzone, wersja) values (4 , 'kliwla@edu.pl', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', true, true, 1);
insert into poziom_dostepu(id, poziom, wersja, aktywny, konto_id) values (1, 'ADMINISTRATOR', 1, true, 1);
insert into poziom_dostepu(id, poziom, wersja, aktywny, konto_id) values (2, 'KLIENT', 1, true, 2);
insert into poziom_dostepu(id, poziom, wersja, aktywny, konto_id) values (3, 'WLASCICIEL_PUBU', 1, true, 3);
insert into poziom_dostepu(id, poziom, wersja, aktywny, konto_id) values (4, 'KLIENT', 1, true, 4);
insert into poziom_dostepu(id, poziom, wersja, aktywny, konto_id) values (5, 'WLASCICIEL_PUBU', 1, true, 4);
insert into dane_osobowe (id,imie,nazwisko) values (1, 'Szymon' , 'Tarwid');
insert into dane_osobowe (id,imie,nazwisko) values (2, 'Wiktor', 'Trzmiel');
insert into dane_osobowe (id,imie,nazwisko) values (3, 'Grzegorz', 'Pawlak');
insert into dane_osobowe (id,imie,nazwisko) values (4, 'Artur', 'Borubar');
insert into administrator(id,nr_telefonu) values (1, '333333333');
insert into klient(id, ksywka) values (2, 'zakolak');
insert into klient(id, ksywka) values (4, 'szymanelis');
insert into wlasciciel_pubu(id, lata_doswiadczenia) values (3,5);
insert into wlasciciel_pubu(id, lata_doswiadczenia) values (5,3);


