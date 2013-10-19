/********************************************************************\

  Run the following command from the directory where CSV files
  with data are located. File names of the latter are hardcoded here.

  USAGE: sqlite3 path/to/database.sqlite3 < path/to/this/import_csv.sql

  Alternatively, fire up the sqlite3 console
    > sqlite3 development.sqlite3
  and run the following commands manually.

\********************************************************************/

/* Purge all data from the following tables */
delete from sentences;
delete from documents;
delete from tokens;
delete from sentence_tokens;

/*
  Prepare for importing new data.
  Tell that columns in source data files are separated by single tab char
*/
.mode tabs

/*
  Import data from CSV files file by file. The general form of the command
  for import is this:
    .import FILENAME TABLENAME
  for example:
    .import path/to/documents.csv documents
*/

.import documents.csv documents
select count(*) from documents;

.import sentences.csv sentences
select count(*) from sentences;

.import tokens.csv tokens
select count(*) from tokens;

/* This is a large table. Be patient */
.import sentence_tokens.csv sentence_tokens
select count(*) from sentence_tokens;

.quit
