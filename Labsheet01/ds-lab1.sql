-- CREATE TABLES --

CREATE TABLE client_tbl(
	clno CHAR(3),
	name VARCHAR(12),
	address VARCHAR(30),
	CONSTRAINT client_pk PRIMARY KEY (clno)
)
/

CREATE TABLE stock_tbl(
	company CHAR(7),
	price NUMBER(6,2),
	divident NUMBER(4,2),
	eps NUMBER(4,2),
	CONSTRAINT stock_pk PRIMARY KEY (company)
)
/

CREATE TABLE trading_tbl(
	company CHAR(7),
	exchange VARCHAR(12),
	CONSTRAINT trading_pk PRIMARY KEY (company, exchange),
	CONSTRAINT fk_stock_trade FOREIGN KEY (company) REFERENCES stock_tbl(company)
)
/

CREATE TABLE purchase_tbl(
	clno CHAR(3),
	company CHAR(7),
	pdate DATE,
	qty NUMBER(6),
	price NUMBER(6,2),
	CONSTRAINT purchase_pk PRIMARY KEY (clno, company, pdate),
	CONSTRAINT fk_client_purchase FOREIGN KEY (clno) REFERENCES client_tbl(clno),
	CONSTRAINT fk_stock_purchase FOREIGN KEY (company) REFERENCES stock_tbl(company)
)
/


-- INSERT DATA TO CLIENT TABLE --


INSERT INTO client_tbl
VALUES ('c01', 'John Smith', '3 East Av, Bentley, WA 6102')
/

INSERT INTO client_tbl
VALUES ('c02', 'Jill Brody', '42 Bent St, Perth, WA 6001')
/


-- INSERT DATA TO STOCK TABLE --

INSERT INTO stock_tbl
VALUES ('BHP', '10.50', '1.50', '3.20')
/

INSERT INTO stock_tbl
VALUES ('IBM', '70.00', '4.25', '10.00')
/

INSERT INTO stock_tbl
VALUES ('INTEL', '76.50', '5.00', '12.40')
/

INSERT INTO stock_tbl
VALUES ('FORD', '40.00', '2.00', '8.50')
/

INSERT INTO stock_tbl
VALUES ('GM', '60.00 ', '2.50', '9.20')
/

INSERT INTO stock_tbl
VALUES ('INFOSYS', '45.00', '3.00', '7.80')
/

-- INSERT DATA TO TRADING TABLE --

INSERT INTO trading_tbl
VALUES ('BHP', 'Sydney')
/

INSERT INTO trading_tbl
VALUES ('BHP', 'New York')
/

INSERT INTO trading_tbl
VALUES ('IBM', 'New York')
/

INSERT INTO trading_tbl
VALUES ('IBM', 'London')
/

INSERT INTO trading_tbl
VALUES ('IBM', 'Tokyo')
/

INSERT INTO trading_tbl
VALUES ('INTEL', 'New York')
/

INSERT INTO trading_tbl
VALUES ('INTEL', 'London')
/

INSERT INTO trading_tbl
VALUES ('FORD', 'New York')
/

INSERT INTO trading_tbl
VALUES ('GM', 'New York')
/

INSERT INTO trading_tbl
VALUES ('INFOSYS', 'New York')
/


-- INSERT DATA TO PURCHASE TABLE --


INSERT INTO purchase_tbl
VALUES ('c01', 'BHP', '02-OCT-2001', '1000', '12.00')
/

INSERT INTO purchase_tbl
VALUES ('c01', 'BHP', '08-JUN-2002', '2000', '10.50')
/

INSERT INTO purchase_tbl
VALUES ('c01', 'IBM', '12-FEB-2000', '500', '58.00')
/

INSERT INTO purchase_tbl
VALUES ('c01', 'IBM', '10-APR-2001', '1200', '65.00')
/

INSERT INTO purchase_tbl
VALUES ('c01', 'INFOSYS', '11-AUG-2001', '1000', '64.00')
/

INSERT INTO purchase_tbl
VALUES ('c02', 'INTEL', '30-JAN-2000', '300', '35.00')
/

INSERT INTO purchase_tbl
VALUES ('c02', 'INTEL', '30-JAN-2001', '400', '54.00')
/

INSERT INTO purchase_tbl
VALUES ('c02', 'INTEL', '10-FEB-2001', '200', '60.00')
/

INSERT INTO purchase_tbl
VALUES ('c02', 'FORD', '05-OCT-1999', '200', '40.00')
/

INSERT INTO purchase_tbl
VALUES ('c02', 'GM', '12-DEC-2000', '500', '55.00')
/


-- QUERIES --


SELECT * FROM client_tbl
/

SELECT * FROM stock_tbl
/

SELECT * FROM trading_tbl
/

SELECT * FROM purchase_tbl
/


-- Q1 --
SELECT DISTINCT c.name, p.company, s.price, s.divident, s.eps
FROM client_tbl c, purchase_tbl p, stock_tbl s
WHERE c.clno = p.clno AND s.company = p.company
/

-- Q2 --
SELECT c.name, s.company, COUNT(s.company) AS shares, CAST(SUM(p.qty * p.price) /  SUM(p.qty) AS DECIMAL(6,2)) AS avg_price
FROM client_tbl c, purchase_tbl p, stock_tbl s
WHERE c.clno = p.clno AND s.company = p.company
GROUP BY c.name, s.company
/

-- Q3 --
SELECT c.name, s.company AS stock, SUM(p.qty) AS shares, SUM(p.qty * s.price) AS cur_val
FROM stock_tbl s, trading_tbl t, purchase_tbl p, client_tbl c
WHERE c.clno = p.clno AND s.company = p.company AND s.company = t.company
AND t.exchange = 'New York'
GROUP BY c.name, s.company
/

-- Q4 --
SELECT c.name, SUM(p.price * p.qty) AS purchases
FROM client_tbl c, purchase_tbl p
WHERE c.clno = p.clno
GROUP BY c.name
/

-- Q5 --
SELECT c.name, s.company, SUM(s.price * p.qty) - SUM(p.price * p.qty) AS profit
FROM client_tbl c, stock_tbl s, purchase_tbl p
WHERE c.clno = p.clno AND s.company = p.company
GROUP BY c.name, s.company
/


commit
/
