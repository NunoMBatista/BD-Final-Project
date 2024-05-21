CREATE TABLE
	patients (
		health_user_id BIGSERIAL NOT NULL,
		person_cc BIGINT,
		PRIMARY KEY (person_cc)
	);

CREATE TABLE
	employees (
		id_contrato SERIAL NOT NULL,
		person_cc BIGINT,
		PRIMARY KEY (person_cc)
	);

CREATE TABLE
	doctors (
		id_lic SERIAL NOT NULL,
		instituto VARCHAR(512) NOT NULL,
		employees_person_cc BIGINT,
		PRIMARY KEY (employees_person_cc)
	);

CREATE TABLE
	nurses (
		hierarchy_level INTEGER NOT NULL,
		employees_person_cc BIGINT,
		PRIMARY KEY (employees_person_cc)
	);

CREATE TABLE
	assistants (
		employees_person_cc BIGINT,
		PRIMARY KEY (employees_person_cc)
	);

CREATE TABLE
	hierarchy (
		level SERIAL,
		nome VARCHAR(512) NOT NULL,
		hierarchy_level INTEGER NOT NULL,
		PRIMARY KEY (level)
	);

CREATE TABLE
	appointments (
		id_app SERIAL,
		data TIMESTAMP NOT NULL,
		billings_id_bill INTEGER NOT NULL,
		doctors_employees_person_cc BIGINT NOT NULL,
		patients_person_cc BIGINT NOT NULL,
		PRIMARY KEY (id_app)
	);

CREATE TABLE
	hospitalizations (
		id_hos SERIAL,
		date_begin DATE NOT NULL,
		date_end DATE NOT NULL,
		room INTEGER NOT NULL,
		nurses_employees_person_cc BIGINT NOT NULL,
		billings_id_bill INTEGER NOT NULL,
		patients_person_cc BIGINT NOT NULL,
		PRIMARY KEY (id_hos)
	);

CREATE TABLE
	surgeries (
		id_sur SERIAL,
		name VARCHAR(512) NOT NULL,
		data TIMESTAMP NOT NULL,
		doctors_employees_person_cc BIGINT NOT NULL,
		hospitalizations_id_hos INTEGER NOT NULL,
		PRIMARY KEY (id_sur)
	);

CREATE TABLE
	roles (
		role_num SERIAL,
		role_name VARCHAR(512) NOT NULL,
		PRIMARY KEY (role_num)
	);

CREATE TABLE
	does_surgery (
		roles_role_num INTEGER,
		surgeries_id_sur INTEGER,
		nurses_employees_person_cc BIGINT,
		PRIMARY KEY (
			roles_role_num,
			surgeries_id_sur,
			nurses_employees_person_cc
		)
	);

CREATE TABLE
	prescriptions (id_pres SERIAL, PRIMARY KEY (id_pres));

CREATE TABLE
	is_comprised_app (
		amount INTEGER NOT NULL,
		medication_id_med INTEGER,
		prescriptions_id_pres INTEGER,
		PRIMARY KEY (medication_id_med, prescriptions_id_pres)
	);

CREATE TABLE
	medication (
		id_med SERIAL,
		name VARCHAR(512) NOT NULL,
		PRIMARY KEY (id_med)
	);

CREATE TABLE
	side_effects (
		id_side SERIAL,
		description VARCHAR(512) NOT NULL,
		PRIMARY KEY (id_side)
	);

CREATE TABLE
	corresponds (
		probability FLOAT (8) NOT NULL,
		severity FLOAT (8) NOT NULL,
		side_effects_id_side INTEGER,
		medication_id_med INTEGER,
		PRIMARY KEY (side_effects_id_side, medication_id_med)
	);

CREATE TABLE
	billings (
		id_bill SERIAL,
		total DOUBLE PRECISION NOT NULL,
		payed DOUBLE PRECISION NOT NULL,
		nif BIGINT NOT NULL,
		PRIMARY KEY (id_bill)
	);

CREATE TABLE
	specialization (
		name VARCHAR(512) NOT NULL,
		id_specialization SERIAL,
		specialization_id_specialization INTEGER NOT NULL,
		PRIMARY KEY (id_specialization)
	);

CREATE TABLE
	person (
		name VARCHAR(512) NOT NULL,
		cc BIGINT,
		email VARCHAR(512),
		contact BIGINT NOT NULL,
		nif BIGINT,
		password VARCHAR(255) NOT NULL,
		PRIMARY KEY (cc)
	);

CREATE TABLE
	doctors_specialization (
		doctors_employees_person_cc BIGINT,
		specialization_id_specialization INTEGER,
		PRIMARY KEY (
			doctors_employees_person_cc,
			specialization_id_specialization
		)
	);

CREATE TABLE
	prescriptions_hospitalizations (
		prescriptions_id_pres INTEGER NOT NULL,
		hospitalizations_id_hos INTEGER,
		PRIMARY KEY (hospitalizations_id_hos)
	);

CREATE TABLE
	appointments_prescriptions (
		appointments_id_app INTEGER,
		prescriptions_id_pres INTEGER NOT NULL,
		PRIMARY KEY (appointments_id_app)
	);

ALTER TABLE patients ADD UNIQUE (health_user_id);

ALTER TABLE patients ADD CONSTRAINT patients_fk1 FOREIGN KEY (person_cc) REFERENCES person (cc);

ALTER TABLE employees ADD UNIQUE (id_contrato);

ALTER TABLE employees ADD CONSTRAINT employees_fk1 FOREIGN KEY (person_cc) REFERENCES person (cc);

ALTER TABLE doctors ADD UNIQUE (id_lic);

ALTER TABLE doctors ADD CONSTRAINT doctors_fk1 FOREIGN KEY (employees_person_cc) REFERENCES employees (person_cc);

ALTER TABLE nurses ADD CONSTRAINT nurses_fk1 FOREIGN KEY (hierarchy_level) REFERENCES hierarchy (level);

ALTER TABLE nurses ADD CONSTRAINT nurses_fk2 FOREIGN KEY (employees_person_cc) REFERENCES employees (person_cc);

ALTER TABLE assistants ADD CONSTRAINT assistants_fk1 FOREIGN KEY (employees_person_cc) REFERENCES employees (person_cc);

ALTER TABLE hierarchy ADD UNIQUE (nome);

ALTER TABLE hierarchy ADD CONSTRAINT hierarchy_fk1 FOREIGN KEY (hierarchy_level) REFERENCES hierarchy (level);

ALTER TABLE appointments ADD CONSTRAINT appointments_fk1 FOREIGN KEY (billings_id_bill) REFERENCES billings (id_bill);

ALTER TABLE appointments ADD CONSTRAINT appointments_fk2 FOREIGN KEY (doctors_employees_person_cc) REFERENCES doctors (employees_person_cc);

ALTER TABLE appointments ADD CONSTRAINT appointments_fk3 FOREIGN KEY (patients_person_cc) REFERENCES patients (person_cc);

ALTER TABLE hospitalizations ADD UNIQUE (billings_id_bill);

ALTER TABLE hospitalizations ADD CONSTRAINT hospitalizations_fk1 FOREIGN KEY (nurses_employees_person_cc) REFERENCES nurses (employees_person_cc);

ALTER TABLE hospitalizations ADD CONSTRAINT hospitalizations_fk2 FOREIGN KEY (billings_id_bill) REFERENCES billings (id_bill);

ALTER TABLE hospitalizations ADD CONSTRAINT hospitalizations_fk3 FOREIGN KEY (patients_person_cc) REFERENCES patients (person_cc);

ALTER TABLE surgeries ADD UNIQUE (name);

ALTER TABLE surgeries ADD CONSTRAINT surgeries_fk1 FOREIGN KEY (doctors_employees_person_cc) REFERENCES doctors (employees_person_cc);

ALTER TABLE surgeries ADD CONSTRAINT surgeries_fk2 FOREIGN KEY (hospitalizations_id_hos) REFERENCES hospitalizations (id_hos);

ALTER TABLE roles ADD UNIQUE (role_name);

ALTER TABLE does_surgery ADD CONSTRAINT does_surgery_fk1 FOREIGN KEY (roles_role_num) REFERENCES roles (role_num);

ALTER TABLE does_surgery ADD CONSTRAINT does_surgery_fk2 FOREIGN KEY (surgeries_id_sur) REFERENCES surgeries (id_sur);

ALTER TABLE does_surgery ADD CONSTRAINT does_surgery_fk3 FOREIGN KEY (nurses_employees_person_cc) REFERENCES nurses (employees_person_cc);

ALTER TABLE is_comprised_app ADD CONSTRAINT is_comprised_app_fk1 FOREIGN KEY (medication_id_med) REFERENCES medication (id_med);

ALTER TABLE is_comprised_app ADD CONSTRAINT is_comprised_app_fk2 FOREIGN KEY (prescriptions_id_pres) REFERENCES prescriptions (id_pres);

ALTER TABLE medication ADD UNIQUE (name);

ALTER TABLE corresponds ADD CONSTRAINT corresponds_fk1 FOREIGN KEY (side_effects_id_side) REFERENCES side_effects (id_side);

ALTER TABLE corresponds ADD CONSTRAINT corresponds_fk2 FOREIGN KEY (medication_id_med) REFERENCES medication (id_med);

ALTER TABLE specialization ADD UNIQUE (name);

ALTER TABLE specialization ADD CONSTRAINT specialization_fk1 FOREIGN KEY (specialization_id_specialization) REFERENCES specialization (id_specialization);

ALTER TABLE person ADD UNIQUE (email, contact);

ALTER TABLE doctors_specialization ADD CONSTRAINT doctors_specialization_fk1 FOREIGN KEY (doctors_employees_person_cc) REFERENCES doctors (employees_person_cc);

ALTER TABLE doctors_specialization ADD CONSTRAINT doctors_specialization_fk2 FOREIGN KEY (specialization_id_specialization) REFERENCES specialization (id_specialization);

ALTER TABLE prescriptions_hospitalizations ADD CONSTRAINT prescriptions_hospitalizations_fk1 FOREIGN KEY (prescriptions_id_pres) REFERENCES prescriptions (id_pres);

ALTER TABLE prescriptions_hospitalizations ADD CONSTRAINT prescriptions_hospitalizations_fk2 FOREIGN KEY (hospitalizations_id_hos) REFERENCES hospitalizations (id_hos);

ALTER TABLE appointments_prescriptions ADD CONSTRAINT appointments_prescriptions_fk1 FOREIGN KEY (appointments_id_app) REFERENCES appointments (id_app);

ALTER TABLE appointments_prescriptions ADD CONSTRAINT appointments_prescriptions_fk2 FOREIGN KEY (prescriptions_id_pres) REFERENCES prescriptions (id_pres);

insert into
	person (name, cc, email, contact, nif, password)
values
	(
		'utente1',
		111111111,
		'utente1@gmail.com',
		911111111,
		211111111,
		'$2b$12$2Ub8XafyuQ5may4KHGa47OzTr370pdoKQ.pvMd/FCKSYDgQA0eoAy'
	),
	(
		'utente2',
		222222222,
		'utente2@gmail.com',
		922222222,
		222222222,
		'$2b$12$KrCa0gy1UA2BpEtPOAQFM.Pif24nQS47OVEX2svy2gMWp0pPiJHvC'
	),
	(
		'utente3',
		333333333,
		'utente3@gmail.com',
		933333333,
		233333333,
		'$2b$12$uwW496fDMuCG9XzEmeVy1.6t1aGkLtLcDyDJfPl4.9b51/sxKa5aO'
	),
	(
		'utente4',
		444444444,
		'utente4@gmail.com',
		944444444,
		244444444,
		'$2b$12$/oVIsmICORLVGRn00IFOY.bzSbd4Sq7zDR/rDcN7/6sT7bBIxJ5.y'
	),
	(
		'utente5',
		555555555,
		'utente5@gmail.com',
		955555555,
		255555555,
		'$2b$12$k1JJXmTj//jN.9qizY2FLOOZaQ1zuum8tZj80Af5tjP2UnjVSFS26'
	),
	(
		'utente6',
		666666666,
		'utente6@gmail.com',
		966666666,
		266666666,
		'$2b$12$xy2cCSXYDkkG/jl3a6zXUuL7G44CwH5ZapCOOHLZe1cGV0wxNpqeu'
	),
	(
		'utente7',
		777777777,
		'utente7@gmail.com',
		977777777,
		277777777,
		'$2b$12$cr.OhrwiAwuV4010s7kzxez4JNGBjHMP25ym6tocD.UuAWCPfxm4e'
	),
	(
		'utente8',
		888888888,
		'utente8@gmail.com',
		988888888,
		288888888,
		'$2b$12$5LbEwogA.F7A3R7ERjVO/u3HOEDVQraHQajM5qmvNt6gfM171xml.'
	),
	(
		'utente9',
		999999999,
		'utente9@gmail.com',
		999999999,
		299999999,
		'$2b$12$eucrZCYm0EE1qoZB2hV/Sudt9gCdEQygRIMCWBlwcuHBRoUeDQLP6'
	),
	(
		'utente10',
		101010101,
		'utente10@gmail.com',
		910101010,
		210101010,
		'$2b$12$hm.RfLC1IlV1ikUuqHaKPuvs18MI4tRtdvCnZGEuL0rHMs9UQr9O.'
	),
	(
		'medico1',
		121212121,
		'medico1@gmail.com',
		912121212,
		212121212,
		'$2b$12$BXQTaTa9cA4JdnOQo13XHe1EskRy2UMq.KnZJ9fhIyvV14vjah1l6'
	),
	(
		'medico2',
		131313131,
		'medico2@gmail.com',
		913131313,
		213131313,
		'$2b$12$ZVyYAhkbBCqp3HbMbEo00OsDwJNmfUGAEn3pGIV36LUwZBi4LXEja'
	),
	(
		'medico3',
		141414141,
		'medico3@gmail.com',
		914141414,
		214141414,
		'$2b$12$qlrTR4pgeBjla5XaSLMXZuU97Ekn2/aBrvjlGoPC6wMwT/bNkLAEe'
	),
	(
		'enfermeiro1',
		115115115,
		'enfermeiro1@gmail.com',
		911511511,
		211511511,
		'$2b$12$4i3fTOl2Ta/aYAqN7stg1uBflLUKMt/2IzILTltrCCTMTMEWVzz9K'
	),
	(
		'enfermeiro2',
		116116116,
		'enfermeiro2@gmail.com',
		911611611,
		211611611,
		'$2b$12$czi38tw7czRhTUbQYt4NMuupbTmDtRvlUjyA69sA4HPTmrNEmG4wa'
	),
	(
		'enfermeiro3',
		117117117,
		'enfermeiro3@gmail.com',
		911711711,
		211711711,
		'$2b$12$8ABKTsCA98/JbnV3dTtCveJff2kZAyIHWwYOxeitnN/fMum3VPhYW'
	),
	(
		'enfermeiro4',
		118118118,
		'enfermeiro4@gmail.com',
		911811811,
		211811811,
		'$2b$12$7rQkfNEw0lZqFwPZwd4T5O3VGF28PZJb41KAAx4rkKb.Xq8uNevuG'
	),
	(
		'enfermeiro5',
		119119119,
		'enfermeiro5@gmail.com',
		911911911,
		211911911,
		'$2b$12$ckfZ3CYIyvE3ysh/Nv73yeF9Zo.vXApkmsu5oPYPZrWuC4KvKM..C'
	),
	(
		'assistente1',
		111111112,
		'assistente1@gmail.com',
		911111112,
		211111112,
		'$2b$12$qb7L3XFUuE/xPLW3SsCpju222M4FmeyeY/uVrwivU.k7CKvVu3jIa'
	),
	(
		'assistente2',
		111111113,
		'assistente2@gmail.com',
		911111113,
		211111113,
		'$2b$12$Ukve1dx1d3JwgX/VaJKlPejy2Ocr.ojqLMm/e1gM0KOaNC1WcvLjO'
	);

insert into
	employees (person_cc, id_contrato)
values
	(121212121, 1),
	(131313131, 2),
	(141414141, 3),
	(115115115, 4),
	(116116116, 5),
	(117117117, 6),
	(118118118, 7),
	(119119119, 8),
	(111111112, 9),
	(111111113, 10);

alter SEQUENCE employees_id_contrato_seq
RESTART WITH 11;

insert into
	assistants (employees_person_cc)
values
	(111111112),
	(111111113);

insert into
	doctors (id_lic, instituto, employees_person_cc)
values
	(1, 'Coimbra', 121212121),
	(2, 'Lisboa', 131313131),
	(3, 'Porto', 141414141);

alter SEQUENCE doctors_id_lic_seq
RESTART WITH 4;

insert into
	specialization (
		name,
		id_specialization,
		specialization_id_specialization
	)
values
	('cardiologia', 1, 1),
	('cardioqualquercoisa', 2, 1),
	('neurologia', 3, 3);

alter SEQUENCE specialization_id_specialization_seq
RESTART WITH 4;

insert into
	doctors_specialization (
		doctors_employees_person_cc,
		specialization_id_specialization
	)
values
	(121212121, 1),
	(131313131, 2),
	(141414141, 3);

insert into
	hierarchy (level, nome, hierarchy_level)
values
	(1, 'Chefe', 1),
	(2, 'Assistente', 1),
	(3, 'Estagiario', 2),
	(4, 'Continuo', 2);

alter SEQUENCE hierarchy_level_seq
RESTART WITH 5;

insert into
	nurses (employees_person_cc, hierarchy_level)
values
	(115115115, 1),
	(116116116, 2),
	(117117117, 3),
	(118118118, 2),
	(119119119, 4);

insert into
	roles (role_num, role_name)
values
	(1, 'role1'),
	(2, 'role2'),
	(3, 'role3');

alter SEQUENCE roles_role_num_seq
RESTART WITH 4;

insert into
	patients (health_user_id, person_cc)
values
	(1, 111111111),
	(2, 222222222),
	(3, 333333333),
	(4, 444444444),
	(5, 555555555),
	(6, 666666666),
	(7, 777777777),
	(8, 888888888),
	(9, 999999999),
	(10, 101010101);

alter SEQUENCE patients_health_user_id_seq
RESTART WITH 11;

insert into
	medication (id_med, name)
values
	(1, 'medicamento1'),
	(2, 'medicamento2'),
	(3, 'medicamento3'),
	(4, 'medicamento4');

alter SEQUENCE medication_id_med_seq
RESTART WITH 5;

insert into
	side_effects (id_side, description)
values
	(1, 'efeito_secundario1'),
	(2, 'efeito_secundario2'),
	(3, 'efeito_secundario3');

alter SEQUENCE side_effects_id_side_seq
RESTART WITH 4;

insert into
	corresponds (
		probability,
		severity,
		side_effects_id_side,
		medication_id_med
	)
values
	(10, 4.5, 1, 1),
	(12.5, 7.5, 1, 2),
	(40, 1.5, 2, 2),
	(90, 0.5, 2, 3),
	(20, 3, 3, 4);

insert into
	billings (id_bill, total, payed, nif)
values
	(1, 100, 0, 211111111),
	(2, 500, 500, 211111111),
	(3, 1000, 50, 222222222),
	(4, 10000, 6000, 211111111);

alter SEQUENCE billings_id_bill_seq
RESTART WITH 5;

insert into
	prescriptions (id_pres)
values
	(1),
	(2);

alter SEQUENCE prescriptions_id_pres_seq
RESTART WITH 3;

insert into
	is_comprised_app (amount, medication_id_med, prescriptions_id_pres)
values
	(1, 1, 1),
	(2, 2, 1),
	(3, 3, 2);

insert into
	appointments (
		id_app,
		data,
		billings_id_bill,
		doctors_employees_person_cc,
		patients_person_cc
	)
values
	(1, '2024-05-16 12:00:00', 1, 121212121, 111111111),
	(2, '2024-05-17 11:00:00', 2, 131313131, 111111111),
	(3, '2024-05-17 10:00:00', 3, 141414141, 222222222);

alter SEQUENCE appointments_id_app_seq
RESTART WITH 4;

insert into
	hospitalizations (
		id_hos,
		date_begin,
		date_end,
		room,
		nurses_employees_person_cc,
		billings_id_bill,
		patients_person_cc
	)
values
	(
		1,
		'2024-04-16',
		'2024-04-17',
		1,
		115115115,
		4,
		111111111
	),
	(
		2,
		'2024-04-16',
		'2024-04-17',
		2,
		116116116,
		2,
		222222222
	);

alter SEQUENCE hospitalizations_id_hos_seq
RESTART WITH 3;

insert into
	prescriptions_hospitalizations (prescriptions_id_pres, hospitalizations_id_hos)
values
	(1, 1),
	(1, 2);

insert into
	appointments_prescriptions (appointments_id_app, prescriptions_id_pres)
values
	(1, 1),
	(2, 2);


--addPerson
create or replace procedure addPerson(name person.name%type, cc person.cc%type, email person.email%type, 
									  contact person.contact%type, nif person.nif%type, password person.password%type)
language plpgsql
as $$
begin
	insert into person
	values (name, cc, email, contact, nif, password);
exception
	when unique_violation then
		raise exception 'Já existe esta pessoa';
	when others then
		raise exception 'error';
end;
$$;

--addEmployee
create or replace procedure addEmployee(cc person.cc%type)
language plpgsql
as $$
begin
	insert into employees values (nextval('employees_id_contrato_seq'), cc);
end;
$$;

--addPatient (função a utilizar na API)
create or replace procedure addPatient(name person.name%type, cc person.cc%type, email person.email%type,
									  contact person.contact%type, nif person.nif%type, password person.password%type)
language plpgsql
as $$
begin
	call addPerson(name, cc, email, contact, nif, password);
	insert into patients values (nextval('patients_health_user_id_seq'), cc);
end;
$$;

--addSpecialization
create or replace procedure addSpecialization(cc person.cc%type, esp specialization.name%type, esp_mae specialization.name%type)
language plpgsql
as $$
declare
	erro varchar(512) = 'error';
	esp_id integer;
	esp_mae_id integer;
begin
	select specialization.id_specialization into esp_id from specialization where specialization.name = esp;
	if not found then
		insert into specialization values (esp, nextval('specialization_id_specialization_seq'), currval('specialization_id_specialization_seq'));
		esp_id := currval('specialization_id_specialization_seq');
	elsif esp_mae == '' then
		erro:='Especialidade já existe';
		raise exception 'erro';
	end if;
	if esp_mae != '' then
		select id_specialization into esp_mae_id from specialization where specialization.name = esp_mae;
		if not found then
			erro := 'Especialidade mãe não exsite';
			raise exception 'erro';
		end if;
		update specialization
		set specialization_id_specialization = esp_mae_id
		where id_specialization = esp_id;
	end if;
exception
	when others then
		raise exception '%',erro;
end;
$$;

--addDoctor (função a usar na API)
create or replace procedure addDoctor(name person.name%type, cc person.cc%type, email person.email%type,
									  contact person.contact%type, nif person.nif%type, password person.password%type,
									 instituto doctors.instituto%type, esp specialization.name%type, esp_mae specialization.name%type default NULL)
language plpgsql
as $$
declare
	erro varchar(512) = 'erro';
	esp_id integer;
begin
	call addPerson(name, cc, email, contact, nif, password);
	call addEmployee(cc);
	insert into doctors
	values(nextval('doctors_id_lic_seq'), instituto, cc);
	if esp_mae is not NULL then
		call addSpecialization(cc, esp, esp_mae);
	end if;
	select id_specialization into esp_id from specialization where specialization.name = esp;
	if not found then
		erro := 'Especialidade não existe';
		raise exception 'erro';
	end if;
	perform * from doctors_specialization 
	where specialization_id_specialization = esp_id and doctors_employees_person_cc = cc;
	if not found then
		insert into doctors_specialization values (cc, esp_id);
	else
		erro := 'Doutor já tem esta especialidade';
		raise exception 'erro';
	end if;
exception
	when others then
		raise exception '%', erro;
end;
$$;

--addAssistant (Função a usar na API)
create or replace procedure addAssistant(name person.name%type, cc person.cc%type, email person.email%type, 
										 contact person.contact%type, nif person.nif%type, password person.password%type)
language plpgsql
as $$
begin
	call addPerson(name, cc, email, contact, nif, password);
	call addEmployee(cc);
	insert into assistants values (cc);
end;
$$;

--addHiearachy
create or replace procedure addHierarchy(hier hierarchy.nome%type, hier_chefe hierarchy.nome%type)
language plpgsql
as $$
declare
	level_id integer;
	level_chefe_id integer;
	erro varchar (512) = 'error';
begin
	select level into level_id from hierarchy where hierarchy.nome = hier;
	if not found then
		if hier_chefe = '' then
			select level into level_chefe_id from hierarchy where level = hierarchy_level;
			insert into hierarchy values(nextval('hierarchy_level_seq'), hier, currval('hierarchy_level_seq'));
			update hierarchy 
			set hierarchy_level = currval('hierarchy_level_seq')
			where level = level_chefe_id;
		else
			select level into level_chefe_id from hierarchy where hierarchy.nome = hier_chefe;
			if not found then
				erro := 'Hierarquia chefe não existe';
				raise exception 'erro';
			end if;
			insert into hierarchy values (nextval('hierarchy_level_seq'), hier, level_chefe_id);
		end if;
	else
		erro:='Hierarquia já existe';
		raise exception 'erro';
	end if;
exception
	when others then
		raise exception '%', erro;
end;
$$;

--addNurse (Função a usar na API)
create or replace procedure addNurse(name person.name%type, cc person.cc%type, email person.email%type,
									  contact person.contact%type, nif person.nif%type, password person.password%type,
									 hier hierarchy.nome%type, hier_chefe hierarchy.nome%type default NULL)
language plpgsql
as $$
declare
	erro varchar(512) = 'error';
	level_id integer;
begin
	call addPerson(name, cc, email, contact, nif, password);
	call addEmployee(cc);
	if hier_chefe is not NULL then
		call addHierarchy(hier, hier_chefe);
	end if;
	select level into level_id from hierarchy where hierarchy.nome = hier;
	if not found then
		erro := 'hierarquia não existe';
		raise exception 'erro';
	end if;
	insert into nurses values (level_id, cc);
exception
	when others then
		raise exception '%', erro;
end;
$$;

--addPrescription para appointments
create type argumento as (amt integer, med character varying);
create or replace procedure addPrescriptionApp(date appointments.data%type, id appointments.id_app%type, variadic meds argumento[])
language plpgsql
as $$
declare
	existe prescriptions.id_pres%type;
	nMeds integer;
	erro varchar(512) = 'erro';
begin
	perform id_app from appointments where data = date and id_app = id;
	if not found then
		erro:='Data e id da consulta nao consistentes';
		raise exception 'erro';
	end if;
	perform appointments_id_app from appointments_prescriptions where id = appointments_id_app;
	if found then
		erro:='Já existe prescrição para esta consulta';
		raise exception 'erro';
	end if;
	drop table if exists auxiliar;
	create local temporary table auxiliar (amount integer, medication varchar(512));
	for i in 1..array_upper(meds, 1)
	loop
		insert into auxiliar values (meds[i].amt, meds[i].med);
	end loop;
	select prescriptions_id_pres into existe
	from is_comprised_app left join (auxiliar left join medication on auxiliar.medication = medication.name) on medication.id_med = is_comprised_app.medication_id_med
	where auxiliar.amount = is_comprised_app.amount
	group by prescriptions_id_pres
	having count(medication_id_med) = array_upper(meds, 1);
	if not found then
		insert into prescriptions values(nextval('prescriptions_id_pres_seq'));
		existe = currval('prescriptions_id_pres_seq');
		select count(id_med) into nMeds
		from medication, auxiliar
		where medication.name = auxiliar.medication;
		if (nMeds != (select count(*) from auxiliar)) then
			erro := 'Pelo menos um dos medicamentos não existe';
			raise exception 'erro';
		end if;
		insert into is_comprised_app (prescriptions_id_pres, amount, medication_id_med)
			select id_pres, sum(amount), medication.id_med
			from (select id_pres from prescriptions where id_pres = currval('prescriptions_id_pres_seq')) as foo, (auxiliar left join medication on auxiliar.medication = medication.name)
			group by id_pres, id_med;
	end if;
	drop table auxiliar;
	insert into appointments_prescriptions values (id, existe);
exception
	when others then
		raise exception '%', erro;
end;
$$;

--addPrescriptions para Hospitalizations
create or replace procedure addPrescriptionHos(date hospitalizations.date_begin%type, id hospitalizations.id_hos%type, variadic meds argumento[])
language plpgsql
as $$
declare
	existe prescriptions.id_pres%type;
	nMeds integer;
	erro varchar(512) = 'erro';
begin
	perform id_hos from hospitalizations where date_begin = date and id_hos = id;
	if not found then
		erro:='Data e id da hospitalização nao consistentes';
		raise exception 'erro';
	end if;
	perform hospitalizations_id_hos from prescriptions_hospitalizations where id = hospitalizations_id_hos;
	if found then
		erro:='Já existe prescrição para esta hospitalização';
		raise exception 'erro';
	end if;
	drop table if exists auxiliar;
	create local temporary table auxiliar (amount integer, medication varchar(512));
	for i in 1..array_upper(meds, 1)
	loop
		insert into auxiliar values (meds[i].amt, meds[i].med);
	end loop;
	select prescriptions_id_pres into existe
	from is_comprised_app left join (auxiliar left join medication on auxiliar.medication = medication.name) on medication.id_med = is_comprised_app.medication_id_med
	where auxiliar.amount = is_comprised_app.amount
	group by prescriptions_id_pres
	having count(medication_id_med) = array_upper(meds, 1);
	if not found then
		insert into prescriptions values(nextval('prescriptions_id_pres_seq'));
		existe := currval('prescriptions_id_pres_seq');
		select count(id_med) into nMeds
		from medication, auxiliar
		where auxiliar.medication = medication.name;
		if (nMeds != (select count(*) from auxiliar)) then
			erro := 'Pelo menos um dos medicamentos não existe';
			raise exception 'erro';
		end if;
		insert into is_comprised_app (prescriptions_id_pres, amount, medication_id_med)
			select id_pres, sum(amount), medication.id_med
			from (select id_pres from prescriptions where id_pres = currval('prescriptions_id_pres_seq')) as foo, (auxiliar left join medication on auxiliar.medication = medication.name)
			group by id_pres, id_med;
	end if;
	drop table auxiliar;
	insert into prescriptions_hospitalizations values (existe, id);
exception
	when others then
		raise exception '%', erro;
end;
$$;

--addMedication
create type novoMedicamento as (prob real, sev real, descr character varying);
create or replace procedure addMedication(med medication.name%type, variadic meds novoMedicamento[])
language plpgsql
as $$
declare
    medi medication.id_med%type;
    side side_effects.id_side%type;
    erro varchar(512) = 'erro';
begin
    perform id_med from medication where medication.name = med;
    if not found then
        insert into medication values (nextval('medication_id_med_seq'), med);
        medi:=currval('medication_id_med_seq');
        for i in 1..array_upper(meds, 1)
        loop
            select id_side into side from side_effects where side_effects.description = meds[i].descr;
            if not found then
                insert into side_effects values (nextval('side_effects_id_side_seq'), meds[i].descr);
                side:=currval('side_effects_id_side_seq');
            end if;
            insert into corresponds (side_effects_id_side, medication_id_med, probability, severity) 
            values (side, medi, meds[i].prob, meds[i].sev); 
        end loop;
    else
        erro := 'Medicamento já existe';
        raise exception 'erro';
    end if;
exception
    when others then
        raise exception '%', erro;
end;
$$;


CREATE OR REPLACE FUNCTION get_top3_patients()
RETURNS TABLE (
    patient_name character varying(512),
    total_payed double precision,
    procedures JSON
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY 
    SELECT
        sub.nome AS patient_name,
        sub.total_payed,
        json_agg(json_build_object('id', sub.app_id, 'doctor_id', sub.doctor_id, 'date', sub.date)) AS procedures

    FROM (
        SELECT
            person.name AS nome, 
            SUM(billings.payed) OVER (PARTITION BY person.name) AS total_payed, 
            appointments.id_app AS app_id,
            appointments.doctors_employees_person_cc AS doctor_id,
            appointments.data AS date
        
        FROM
            person 
            JOIN patients ON person.cc = patients.person_cc
            JOIN appointments ON patients.person_cc = appointments.patients_person_cc
            JOIN billings ON appointments.billings_id_bill = billings.id_bill
        WHERE
       	    EXTRACT(MONTH FROM appointments.data) = EXTRACT(MONTH FROM CURRENT_DATE)
            AND EXTRACT(YEAR FROM appointments.data) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) AS sub

    GROUP BY
        sub.nome,
        sub.total_payed

    ORDER BY
        sub.total_payed DESC,
        sub.nome
    LIMIT 3;
END; $$;

CREATE OR REPLACE FUNCTION get_daily_summary(p_date date)
RETURNS TABLE (
    surgeries bigint,
    prescriptions bigint,
    amount_spent double precision
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        COUNT(DISTINCT id_sur) AS surgeries, 
        COUNT(DISTINCT prescriptions_id_pres) AS prescriptions, 
        SUM(payed) AS amount_spent
    FROM 
        hospitalizations
        JOIN billings ON hospitalizations.billings_id_bill = billings.id_bill
        JOIN surgeries ON hospitalizations.id_hos = surgeries.hospitalizations_id_hos
        JOIN prescriptions_hospitalizations ON hospitalizations.id_hos = prescriptions_hospitalizations.hospitalizations_id_hos
    WHERE 
        hospitalizations.date_begin = p_date;
END; $$;

CREATE OR REPLACE FUNCTION get_top3_patients()
RETURNS TABLE (
    patient_name character varying(512),
    total_payed double precision,
    procedures JSON
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY 
    SELECT
        sub.nome AS patient_name,
        sub.total_payed,
        json_agg(json_build_object('id', sub.app_id, 'doctor_id', sub.doctor_id, 'date', sub.date)) AS procedures

    FROM (
        SELECT
            person.name AS nome, 
            SUM(billings.payed) OVER (PARTITION BY person.name) AS total_payed, 
            appointments.id_app AS app_id,
            appointments.doctors_employees_person_cc AS doctor_id,
            appointments.data AS date
        
        FROM
            person 
            JOIN patients ON person.cc = patients.person_cc
            JOIN appointments ON patients.person_cc = appointments.patients_person_cc
            JOIN billings ON appointments.billings_id_bill = billings.id_bill
        WHERE
       	    EXTRACT(MONTH FROM appointments.data) = EXTRACT(MONTH FROM CURRENT_DATE)
            AND EXTRACT(YEAR FROM appointments.data) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) AS sub

    GROUP BY
        sub.nome,
        sub.total_payed

    ORDER BY
        sub.total_payed DESC,
        sub.nome
    LIMIT 3;
END; $$;

CREATE OR REPLACE FUNCTION pay_bill(bill_id integer, amount double precision)
RETURNS double precision
LANGUAGE plpgsql
AS $$
DECLARE
    total_bill double precision;
    payed_amount double precision;
BEGIN
    SELECT b.total, b.payed INTO total_bill, payed_amount
    FROM billings AS b
    WHERE b.id_bill = bill_id;

    IF amount <= (total_bill - payed_amount) THEN
        UPDATE billings
        SET payed = payed + amount
        WHERE id_bill = bill_id;
        
        -- Calculate and return the remaining value
        RETURN total_bill - (payed_amount + amount);
    ELSE
        RAISE EXCEPTION 'Payment amount is too much';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error occurred: %', SQLERRM;
END;
$$;

-- Create a function to check if a doctor is available
CREATE OR REPLACE FUNCTION is_doctor_available(doctor_id bigint, appointment_date timestamp without time zone)
RETURNS BOOLEAN AS $$
DECLARE
    is_available BOOLEAN;
BEGIN
    SELECT NOT EXISTS (
        SELECT 1 FROM appointments 
        WHERE doctor_id = doctors_employees_person_cc 
        AND appointment_date BETWEEN (data - INTERVAL '30 minutes') AND (data + INTERVAL '30 minutes')
    ) INTO is_available;

    RETURN is_available;
END;
$$ LANGUAGE plpgsql;

-- Create a function to create a new bill
CREATE OR REPLACE FUNCTION create_new_bill()
RETURNS TRIGGER AS $$
DECLARE
    nif bigint;
BEGIN
    -- Get the NIF from the patients table
    SELECT person.nif INTO nif FROM person WHERE cc = NEW.patients_person_cc;

    -- Create a new bill and get its id
    INSERT INTO billings (total, payed, NIF) 
    VALUES (100, 0, nif) 
    RETURNING id_bill INTO NEW.billings_id_bill;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_bill_trigger
BEFORE INSERT ON appointments
FOR EACH ROW
EXECUTE FUNCTION create_new_bill();

-- Create a function to schedule an appointment
CREATE OR REPLACE FUNCTION schedule_appointment(doctor_id bigint, appointment_date timestamp without time zone, person_cc bigint)
RETURNS TABLE (status_code INT, errors TEXT, appointment_id INT, bill_id INT) AS $$
BEGIN
    IF NOT is_doctor_available(doctor_id, appointment_date) THEN
        status_code := 400;
        errors := 'Doctor is not available on the specified date';
        RETURN NEXT;
    ELSE
        INSERT INTO appointments (data, doctors_employees_person_cc, patients_person_cc) 
        VALUES (appointment_date, doctor_id, person_cc) 
        RETURNING id_app, billings_id_bill INTO appointment_id, bill_id;
        status_code := 200;
        RETURN NEXT;
    END IF;
EXCEPTION
    WHEN others THEN
        status_code := 500;
        errors := SQLERRM;
        RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE nurse_role AS (
    nurse_id BIGINT,
    role varchar
);

DROP FUNCTION is_doctor_available(bigint,timestamp without time zone);
CREATE OR REPLACE FUNCTION is_doctor_available(doctor_id bigint, input_date timestamp without time zone)
RETURNS BOOLEAN AS $$
DECLARE
    is_available BOOLEAN;
BEGIN
    SELECT NOT EXISTS (
        SELECT 1 FROM appointments 
        WHERE doctor_id = doctors_employees_person_cc 
        AND appointments.data BETWEEN (input_date - INTERVAL '30 minutes') AND (input_date + INTERVAL '30 minutes')
    ) AND NOT EXISTS (
        SELECT 1 FROM surgeries 
        JOIN does_surgery ON surgeries.id_sur = does_surgery.surgeries_id_sur
        WHERE doctors_employees_person_cc = doctor_id 
        AND data BETWEEN (input_date - INTERVAL '30 minutes') AND (input_date + INTERVAL '30 minutes')
    ) INTO is_available;

    RETURN is_available;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_nurse_available(nurse_id bigint, input_date timestamp without time zone)
RETURNS BOOLEAN AS $$
DECLARE
    is_available BOOLEAN;
BEGIN
    SELECT NOT EXISTS (
        SELECT 1 FROM surgeries 
        JOIN does_surgery ON surgeries.id_sur = does_surgery.surgeries_id_sur
        WHERE nurses_employees_person_cc = nurse_id 
        AND data BETWEEN (input_date - INTERVAL '30 minutes') AND (input_date + INTERVAL '30 minutes')
    ) INTO is_available;

    RETURN is_available;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_new_bill_surgery()
RETURNS TRIGGER AS $$
DECLARE
    nif bigint;
BEGIN
    SELECT person.nif INTO nif FROM person WHERE cc = NEW.patients_person_cc;
    INSERT INTO billings (total, payed, NIF) 
    VALUES (300, 0, nif) 
    RETURNING id_bill INTO NEW.billings_id_bill;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_bill_trigger
BEFORE INSERT ON hospitalizations
FOR EACH ROW
EXECUTE FUNCTION create_new_bill_surgery();

CREATE OR REPLACE FUNCTION schedule_surgery(input_patient_id bigint, input_doctor_id bigint, nurses nurse_role[], input_date timestamp without time zone, input_hospitalization_id int, surgery_name varchar)
RETURNS TABLE (status_code INT, errors TEXT, returned_hospitalization_id INT, surgery_id INT, patient_id INT, doctor_id INT, date timestamp without time zone) AS $$
DECLARE
    nurse_role nurse_role;
    new_hospitalization_id bigint;
    new_surgery_id bigint;
BEGIN
    -- Check if the doctor is available
    IF NOT is_doctor_available(input_doctor_id, input_date) THEN
        RAISE EXCEPTION 'Doctor is not available on the specified date' USING ERRCODE = '45000';
    END IF;

    -- Check if the nurses are available
    FOREACH nurse_role IN ARRAY nurses LOOP
        IF NOT is_nurse_available(nurse_role.nurse_id, input_date) THEN
            RAISE EXCEPTION 'Nurse with id % is not available on the specified date', nurse_role.nurse_id USING ERRCODE = '45000';
        END IF;
    END LOOP;

    -- If a hospitalization_id is provided, check if it exists
    IF input_hospitalization_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM hospitalizations WHERE id_hos = input_hospitalization_id) THEN
            RAISE EXCEPTION 'Hospitalization with id % does not exist', input_hospitalization_id USING ERRCODE = '45000';
        END IF;
    -- If a hospitalization_id is not provided, create a new hospitalization and a new bill
    ELSE
        INSERT INTO hospitalizations (date_begin, date_end, room, nurses_employees_person_cc, patients_person_cc) 
        VALUES (input_date, input_date, new_room, (SELECT employees_person_cc FROM nurses WHERE hierarchy_level = 1 LIMIT 1), input_patient_id) 
        RETURNING id_hos INTO new_hospitalization_id;
    END IF;

    -- Create a new surgery and associate it with the doctor and the hospitalization
    INSERT INTO surgeries (name, data, doctors_employees_person_cc, hospitalizations_id_hos) 
    VALUES (surgery_name, input_date, input_doctor_id, COALESCE(input_hospitalization_id, new_hospitalization_id)) 
    RETURNING id_sur INTO new_surgery_id;

    -- For each nurse, create a record in the does_surgery table
    FOREACH nurse_role IN ARRAY nurses LOOP
        INSERT INTO does_surgery (roles_role_num, surgeries_id_sur, nurses_employees_person_cc) 
        VALUES ((SELECT role_num FROM roles WHERE role_name = nurse_role.role), new_surgery_id, nurse_role.nurse_id);
    END LOOP;

    RETURN QUERY SELECT 200, NULL, COALESCE(input_hospitalization_id, new_hospitalization_id)::int, new_surgery_id::int, input_patient_id::int, input_doctor_id::int, input_date;
EXCEPTION
    WHEN others THEN
        RETURN QUERY SELECT 500, SQLERRM, NULL::int, NULL::int, NULL::int, NULL::int, NULL::timestamp without time zone;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION schedule_surgery(
    input_patient_id bigint, 
    input_doctor_id bigint, 
    nurses nurse_role[], 
    input_date timestamp without time zone, 
    surgery_name varchar,
    hospitalization_date_begin DATE,
    hospitalization_date_end DATE,
    hospitalization_room INT,
    hospitalization_nurse_id BIGINT
)
RETURNS TABLE (
    status_code INT, 
    errors TEXT, 
    returned_hospitalization_id INT, 
    surgery_id INT, 
    patient_id INT, 
    doctor_id INT, 
    date timestamp without time zone
) AS $$
DECLARE
    nurse_role nurse_role;
    new_hospitalization_id bigint;
    new_surgery_id bigint;
BEGIN
    -- Check if the doctor is available
    IF NOT is_doctor_available(input_doctor_id, input_date) THEN
        RAISE EXCEPTION 'Doctor is not available on the specified date' USING ERRCODE = '45000';
    END IF;

    -- Check if the nurses are available
    FOREACH nurse_role IN ARRAY nurses LOOP
        IF NOT is_nurse_available(nurse_role.nurse_id, input_date) THEN
            RAISE EXCEPTION 'Nurse with id % is not available on the specified date', nurse_role.nurse_id USING ERRCODE = '45000';
        END IF;
    END LOOP;

    -- Create a new hospitalization
    INSERT INTO hospitalizations (date_begin, date_end, room, nurses_employees_person_cc, patients_person_cc) 
    VALUES (hospitalization_date_begin, hospitalization_date_end, hospitalization_room, hospitalization_nurse_id, input_patient_id) 
    RETURNING id_hos INTO new_hospitalization_id;

    -- Create a new surgery and associate it with the doctor and the hospitalization
    INSERT INTO surgeries (name, data, doctors_employees_person_cc, hospitalizations_id_hos) 
    VALUES (surgery_name, input_date, input_doctor_id, new_hospitalization_id) 
    RETURNING id_sur INTO new_surgery_id;

    -- For each nurse, create a record in the does_surgery table
    FOREACH nurse_role IN ARRAY nurses LOOP
        INSERT INTO does_surgery (roles_role_num, surgeries_id_sur, nurses_employees_person_cc) 
        VALUES ((SELECT role_num FROM roles WHERE role_name = nurse_role.role), new_surgery_id, nurse_role.nurse_id);
    END LOOP;

    RETURN QUERY SELECT 200, NULL, new_hospitalization_id::int, new_surgery_id::int, input_patient_id::int, input_doctor_id::int, input_date;
EXCEPTION
    WHEN others THEN
        RETURN QUERY SELECT 500, SQLERRM, NULL::int, NULL::int, NULL::int, NULL::int, NULL::timestamp without time zone;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_new_bill_surgery()
RETURNS TRIGGER AS $$
DECLARE
    new_bill_id bigint;
BEGIN
    -- Create a new bill
    INSERT INTO billings (total, payed, NIF) 
    VALUES (300, 0, (SELECT nif FROM person WHERE cc = NEW.patients_person_cc)) 
    RETURNING id_bill INTO new_bill_id;

    -- Set the billings_id_bill field of the new hospitalization
    NEW.billings_id_bill = new_bill_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_bill_trigger_hosp
BEFORE INSERT ON hospitalizations
FOR EACH ROW
EXECUTE FUNCTION create_new_bill_surgery();


