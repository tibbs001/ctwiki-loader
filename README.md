# CT-WikiData Loader

Description:  This app facilitates the import of basic clinical trials metadata into wikidata. The data source is clinicaltrials.gov.

In short: this app discovers which trials registered in clinicaltrials.org are not yet in wikidata (using the NCT ID), 
gathers basic metadata about those trials, formats that metadata into a quickstatement transaction and then exports 
the formatted transactions to a set of files that can be loaded into wikidata using the toolforge quickstatements 
import interface (https://quickstatements.toolforge.org/#/batches)

This is a headless ruby on rails app; all code is in the models.

Before running the primary job that creates loadable clinical trials data files, you need to generate a set of lookup 
tables (saved to a local relational database) which provide a way for the main job (the one that actually exports the loadable 
clinical trials data files) to retrieve wikidata q-codes that allow this app to associate each trial to existing wikidata 
entities that are related to each clinical trial such as authors, interventions, conditions & journals.

(The primary job can be run from a ruby console session: Util::StudyPrepper.new.run)

## Dependencies

Note: all external dependencies are freely available; it just takes some time/effort to setup.

* AACT Database Account. 
** Create your account here: https://aact.ctti-clinicaltrials.org/users/sign_up
** Learn about connecting here: https://aact.ctti-clinicaltrials.org/connect
** AACT is a postgres database. If you register, get an account & have postgres installed on your machine, you should be able to access the database directly with this command:
   psql --host aact-db.ctti-clinicaltrials.org --port=5432 --username=your-aact-id --dbname=aact
** Update config/database.yml:  replace the string 'your-aact-id' with the login name you created in AACT.

* Toolforge Quickstatements Account: https://quickstatements.toolforge.org/#/batches
** You will need this account to load the files containing clinical trials data created by this app

* Access to https://query.wikidata.org/  (The file in this app:  app/models/util/wiki_data_manager.rb sends sparql queries to this endpoint)

## Getting started

* Install:
** ruby 2.4.5 (You need ruby/rails installed locally since this app is not yet containerized)
** rails 4.2.11.1

* (Need to create a separate database or schema for this because we cannot write to the AACT database we're referencing)
* Run migrations to create the lookup tables  (bundle exec rake db:migrate)  

### These commands will populate the lookup tables so that relationships can be defined.

Lookup::Publication.populate
Lookup::Author.populate
Lookup::Intervention.populate
Lookup::Condition.populate
Lookup::Journal.populate
Util::StudyPrepper.new.run
Util::PubPrepper.new.run
Util::Updater.new.load_pubs

## Dependencies


### Addendum

Apologize if this code is clumsy and unpolished. Did my best; I'm not a natural.

