----------------------------------------------------------------------------------------------------------------------
--- SQL SCRIPT PARA CRIAÇÃO DOS SCHEMAS/DB DO ZABBIX E GRAFANA NO POSTGRESQL ---
--- AUTOR: FRANCO FERRACIOLLI ---

--- CRIA DIRETORIO DA TABLESPACE DO BANCO ZABBIX --
\! mkdir /var/lib/postgresql/14/main/zabbixdata && chown postgres:postgres /var/lib/postgresql/14/main/zabbixdata
--- CRIA DIRETORIO DA TABLESPACE DO BANCO GRAFANA --
\! mkdir /var/lib/postgresql/14/main/grafanadata && chown postgres:postgres /var/lib/postgresql/14/main/grafanadata

--- CRIA A ROLE DO ZABBIX ---
DROP DATABASE IF EXISTS zabbix;
DROP ROLE IF EXISTS zabbix;
--- MEDIDAS DE SEGURANÇA PARA O PROCESSO
CREATE ROLE zabbix WITH
	LOGIN
	REPLICATION
	PASSWORD '&#dPSCNvnzHj';

CREATE TABLESPACE zbxdbs OWNER zabbix LOCATION '/var/lib/postgresql/14/main/zabbixdata';
--- IGNORAR O ALERTA DE SEGURANÇA ---

--- CRIA O BANCO DE DADOS DO ZABBIX E APONTA PARA A TABLESPACE ---
CREATE DATABASE zabbix 
WITH 
	ENCODING 'UTF8'
	LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8'
	OWNER zabbix
	TABLESPACE zbxdbs
	CONNECTION LIMIT 250
	ALLOW_CONNECTIONS true;
	
	
--- CHAMA O SCRIPT PARA IMPORTAÇÂO DO SCHEMA --- 
\! zcat /usr/share/doc/zabbix-sql-scripts/postgresql/server.sql.gz | psql -U zabbix -h 127.0.0.1  -d zabbix

--- GRAFANA --- 
--- CRIA O BANCO DE DADOS DO GRAFANA ---
DROP DATABASE IF EXISTS grafana;
DROP ROLE IF EXISTS grafana;
--- MEDIDAS DE SEGURANÇA PARA O PROCESSO
CREATE ROLE grafana WITH
	LOGIN
	REPLICATION
	PASSWORD 'h&wAKL4GbbYy';

CREATE TABLESPACE grafanadbs OWNER grafana LOCATION '/var/lib/postgresql/14/main/grafanadata';

CREATE DATABASE grafana
WITH 
	ENCODING 'UTF8'
	LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8'
	OWNER grafana
	TABLESPACE grafanadbs
	CONNECTION LIMIT -1
	ALLOW_CONNECTIONS true;
	

\c grafana

CREATE TABLE session (
   key CHAR(16) NOT NULL,
   data bytea,
   expiry INT NOT NULL,
   PRIMARY KEY (key)
);

--- VERIFICAÇÃO DE DISPONIBILIDADE DOS DBS ---
\! pg_isready 

--- EXECUTA O SCRIPT DE CRIAÇÃO DO TIMESCALEDB

\! echo "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;" | psql -U postgres -d zabbix

\! cat /usr/share/doc/zabbix-sql-scripts/postgresql/timescaledb.sql | psql -U zabbix -h 127.0.0.1  -d zabbix