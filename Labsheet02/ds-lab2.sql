--CREATE OBJECTS--

/* 
*Since emp_t requires a REF from dep_t we have to
*create a demo dept_t just to make the reference
*/

CREATE TYPE dept_t
/

CREATE TYPE emp_t AS OBJECT(
	empno CHAR(6),
	firstname VARCHAR(12),
	lastname VARCHAR(15),
	workdept REF dept_t,
	sex CHAR(1),
	birthdate DATE,
	salary NUMBER(8,2)
)
/

CREATE TYPE dept_t AS OBJECT(
	deptno CHAR(3),
	deptname VARCHAR(36),
	mgrno REF emp_t,
	admrdept REF dept_t
)
/

-- CREATE TABLES --

CREATE TABLE oremp_tbl OF emp_t(
	CONSTRAINT oremp_pk PRIMARY KEY(empno),
	CONSTRAINT oremp_fn_nn firstname NOT NULL,
	CONSTRAINT oremp_ln_nn lastname NOT NULL,
	CONSTRAINT oremp_ck_sx sex CHECK(sex = 'M' OR sex = 'F' OR sex = 'm' OR sex = 'f')
)
/

/*
*workdept cannot be set as a foreign key yet
*/

CREATE TABLE ordept_tbl OF dept_t(
	CONSTRAINT ordept_pk PRIMARY KEY(deptno),
	CONSTRAINT ordept_dn_nn deptname NOT NULL,
	CONSTRAINT emp_dept_mgr_fk FOREIGN KEY(mgrno) REFERENCES oremp_tbl
)
/

/*
*altering table to set workdept as a foreign key
*/
ALTER TABLE oremp_tbl
	ADD CONSTRAINT dept_emp_wrk_fk FOREIGN KEY(workdept) REFERENCES ordept_tbl
/

/*
*altering table to set admrdept as a foreign key
*/

ALTER TABLE ordept_tbl
	ADD CONSTRAINT dept_adm_fk FOREIGN KEY(admrdept) REFERENCES ordept_tbl
/


-- INSERT VALUES TO DEPT_TBL WITH NULL EMP REF --

INSERT INTO ordept_tbl VALUES(
	dept_t('A00', 'SPIFFY COMPUTER SERVICE DIV.', null, null)
)
/

INSERT INTO ordept_tbl VALUES(
	dept_t('B01', 'PLANNING', null,
		(SELECT REF(D) FROM ordept_tbl D WHERE D.deptno = 'A00')
))
/

INSERT INTO ordept_tbl VALUES(
	dept_t('C01', 'INFORMATION CENTRE', null,
		(SELECT REF(D) FROM ordept_tbl D WHERE D.deptno = 'A00')
))
/

INSERT INTO ordept_tbl VALUES(
	dept_t('D01', 'DEVELOPMENT CENTRE', null,
		(SELECT REF(D) FROM ordept_tbl D WHERE D.deptno = 'C01')
))
/

-- UPDATE ordept_tbl TO SET 'A00' VALUE --

UPDATE ordept_tbl d
SET d.admrdept = (SELECT REF(D) FROM ordept_tbl D WHERE D.deptno = 'A00')
WHERE d.deptno = 'A00'
/


-- INSERT VALUES TO oremp_tbl --

INSERT INTO oremp_tbl VALUES(
	emp_t('000010', 'CHRISTINE', 'HAAS',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'A00'),
	'F', '14-AUG-53', '72750')
)
/

INSERT INTO oremp_tbl VALUES(
	emp_t('000020', 'MICHAEL', 'THOMPSON',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'B01'),
	'M', '02-FEB-68', '61250')
)
/

INSERT INTO oremp_tbl VALUES(
	emp_t('000030', 'SALLY', 'KWAN',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'C01'),
	'F', '11-MAY-71', '58250')
)
/

INSERT INTO oremp_tbl VALUES(
	emp_t('000060', 'IRVING', 'STERN',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'D01'),
	'M', '07-JUL-65', '55555')
)
/

INSERT INTO oremp_tbl VALUES(
	emp_t('000070', 'EVA', 'PULASKI',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'D01'),
	'F', '26-MAY-73', '56170')
)
/

INSERT INTO oremp_tbl VALUES(
	emp_t('000050', 'JOHN', 'GEYER',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'C01'),
	'M', '15-SEP-55', '60175')
)
/

INSERT INTO oremp_tbl VALUES(
	emp_t('000090', 'EILEEN', 'HENDERSON',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'B01'),
	'F', '15-MAY-61', '49750')
)
/

INSERT INTO oremp_tbl VALUES(
	emp_t('000100', 'THEODORE', 'SPENSER',
		(SELECT REF(D) FROM ordept_tbl D WHERE deptno = 'B01'),
	'M', '18-DEC-76', '46150')
)
/


-- UPDATE NULL VALUES OF ordept_tbl --

UPDATE ordept_tbl D
SET D.mgrno = (SELECT REF(M) FROM oremp_tbl M WHERE empno = '000010')
WHERE D.deptno = 'A00'
/

UPDATE ordept_tbl D
SET D.mgrno = (SELECT REF(M) FROM oremp_tbl M WHERE empno = '000020')
WHERE D.deptno = 'B01'
/

UPDATE ordept_tbl D
SET D.mgrno = (SELECT REF(M) FROM oremp_tbl M WHERE empno = '000030')
WHERE D.deptno = 'C01'
/

UPDATE ordept_tbl D
SET D.mgrno = (SELECT REF(M) FROM oremp_tbl M WHERE empno = '000060')
WHERE D.deptno = 'D01'
/

commit
/

-- (Q2) QUERIES --

-- (A) --
SELECT d.deptname AS DEPARTMENT, d.mgrno.lastname AS MANAGER
FROM ordept_tbl d
/

-- (B) --
SELECT e.empno, e.lastname, e.workdept.deptname AS DEPARTMENT
FROM oremp_tbl e
/

-- (C) --
SELECT d.deptno, d.deptname, d.admrdept.deptname AS ADMIN_DEPT
FROM ordept_tbl d
/

-- (D) --
SELECT d.deptno, d.deptname, d.admrdept.deptname AS ADMINIST, d.admrdept.mgrno.lastname AS ADMINIST_MNG
FROM ordept_tbl d
/

-- (E) --
SELECT e.empno, e.firstname, e.lastname, e.salary, e.workdept.mgrno.lastname AS MANAGER, e.workdept.mgrno.salary AS MNGR_SALARY 
FROM oremp_tbl e 
/

-- (F) --
SELECT e.workdept.deptno AS DEPTNO, e.workdept.deptname AS DEPT,
	(SELECT AVG(e1.salary)
	FROM oremp_tbl e1
	WHERE e1.workdept.deptno = e.workdept.deptno
	AND e1.sex = 'M') AS AVG_MALE_SAL,
	(SELECT AVG(e1.salary)
	FROM oremp_tbl e1
	WHERE e1.workdept.deptno = e.workdept.deptno
	AND e1.sex = 'F') AS AVG_FEMALE_SAL
FROM oremp_tbl e
GROUP BY e.workdept.deptno, e.workdept.deptname
/

-- ANOTHER SOLUTION FOR QUERY (F) --

SELECT *
FROM  
	(SELECT em.workdept.deptno AS DEPTNO, em.workdept.deptname AS DEPT, AVG(em.salary) AS AVG_MALE_SAL
	FROM oremp_tbl em
	WHERE em.sex = 'M'
	GROUP BY em.workdept.deptno , em.workdept.deptname) maleEmp
JOIN
	(SELECT ef.workdept.deptno AS DEPTNO, ef.workdept.deptname AS DEPT, AVG(ef.salary) AS AVG_FEMALE_SAL
	FROM oremp_tbl ef
	WHERE ef.sex = 'F'
	GROUP BY ef.workdept.deptno , ef.workdept.deptname) femaleEmp
ON  maleEmp.deptno = femaleEmp.deptno
/


