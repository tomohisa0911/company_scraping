drop table if exists companies;
create table companies (
	id integer primary key,
	name TEXT,
	address TEXT,
	connum TEXT,
	mail TEXT,
	site_url TEXT,
	a_href TEXT,
	created_at,
	updated_at
);

drop table if exists urllists;
create table urllists (
	id integer primary key,
	url TEXT,
	created_at,
	updated_at
);