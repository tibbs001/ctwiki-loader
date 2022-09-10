SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ctgov; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ctgov;


--
-- Name: lookup; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA lookup;


--
-- Name: pubmed; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pubmed;


--
-- Name: category_insert_function(); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.category_insert_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          INSERT INTO ctgov.search_results (id, nct_id, name, created_at, updated_at, grouping, study_search_id)

          VALUES (NEW.id, NEW.nct_id, NEW.name, NEW.created_at, NEW.updated_at, NEW.grouping, NEW.study_search_id);
          RETURN NEW;
        END;
        $$;


--
-- Name: count_estimate(text); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.count_estimate(query text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        rec   record;
        ROWS  INTEGER;
      BEGIN
        FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
          ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
          EXIT WHEN ROWS IS NOT NULL;
      END LOOP;

      RETURN ROWS;
      END
      $$;


--
-- Name: ids_for_org(character varying); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.ids_for_org(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$
      SELECT DISTINCT nct_id FROM responsible_parties WHERE lower(affiliation) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM facilities WHERE lower(name) like lower($1) or lower(city) like lower($1) or lower(state) like lower($1) or lower(country) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM sponsors WHERE lower(name) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM result_contacts WHERE lower(organization) like lower($1)
      ;
      $_$;


--
-- Name: ids_for_term(character varying); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.ids_for_term(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$

        SELECT DISTINCT nct_id FROM browse_conditions WHERE downcase_mesh_term like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM browse_interventions WHERE downcase_mesh_term like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM studies WHERE lower(brief_title) like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM keywords WHERE lower(name) like lower($1)
        ;
        $_$;


--
-- Name: study_summaries_for_condition(character varying); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.study_summaries_for_condition(character varying) RETURNS TABLE(nct_id character varying, title text, recruitment character varying, were_results_reported boolean, conditions text, interventions text, gender character varying, age text, phase character varying, enrollment integer, study_type character varying, sponsors text, other_ids text, study_first_submitted_date date, start_date date, completion_month_year character varying, last_update_submitted_date date, verification_month_year character varying, results_first_submitted_date date, acronym character varying, primary_completion_month_year character varying, outcome_measures text, disposition_first_submitted_date date, allocation character varying, intervention_model character varying, observational_model character varying, primary_purpose character varying, time_perspective character varying, masking character varying, masking_description text, intervention_model_description text, subject_masked boolean, caregiver_masked boolean, investigator_masked boolean, outcomes_assessor_masked boolean, number_of_facilities integer)
    LANGUAGE sql
    AS $_$

      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          bc.mesh_term,
          i.names as interventions,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as design_outcomes,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities

      FROM studies s
        INNER JOIN browse_conditions         bc ON s.nct_id = bc.nct_id and bc.downcase_mesh_term  like lower($1)
        LEFT OUTER JOIN calculated_values    cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions       c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions    i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors         sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities        e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information   id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes  o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs              d  ON s.nct_id = d.nct_id

     UNION

      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          bc.name,
          i.names as interventions,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as design_outcomes,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities

      FROM studies s
        INNER JOIN conditions                bc ON s.nct_id = bc.nct_id and bc.downcase_name like lower($1)
        LEFT OUTER JOIN calculated_values    cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions       c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions    i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors         sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities        e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information   id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes  o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs              d  ON s.nct_id = d.nct_id

     UNION

      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          k.name,
          i.names as interventions,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as outcome_measures,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities

      FROM studies s
        INNER JOIN keywords k ON s.nct_id = k.nct_id and k.downcase_name like lower($1)
        LEFT OUTER JOIN calculated_values   cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions      c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions   i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors        sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities       e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information  id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs             d  ON s.nct_id = d.nct_id

        ;
        $_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.active_storage_attachments_id_seq OWNED BY ctgov.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.active_storage_blobs_id_seq OWNED BY ctgov.active_storage_blobs.id;


--
-- Name: browse_conditions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.browse_conditions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying,
    mesh_type character varying
);


--
-- Name: all_browse_conditions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_browse_conditions AS
 SELECT browse_conditions.nct_id,
    array_to_string(array_agg(DISTINCT browse_conditions.mesh_term), '|'::text) AS names
   FROM ctgov.browse_conditions
  GROUP BY browse_conditions.nct_id;


--
-- Name: browse_interventions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.browse_interventions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying,
    mesh_type character varying
);


--
-- Name: all_browse_interventions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_browse_interventions AS
 SELECT browse_interventions.nct_id,
    array_to_string(array_agg(browse_interventions.mesh_term), '|'::text) AS names
   FROM ctgov.browse_interventions
  GROUP BY browse_interventions.nct_id;


--
-- Name: facilities; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.facilities (
    id integer NOT NULL,
    nct_id character varying,
    status character varying,
    name character varying,
    city character varying,
    state character varying,
    zip character varying,
    country character varying
);


--
-- Name: all_cities; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_cities AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(DISTINCT facilities.city), '|'::text) AS names
   FROM ctgov.facilities
  GROUP BY facilities.nct_id;


--
-- Name: conditions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.conditions (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: all_conditions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_conditions AS
 SELECT conditions.nct_id,
    array_to_string(array_agg(DISTINCT conditions.name), '|'::text) AS names
   FROM ctgov.conditions
  GROUP BY conditions.nct_id;


--
-- Name: countries; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.countries (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    removed boolean
);


--
-- Name: all_countries; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_countries AS
 SELECT countries.nct_id,
    array_to_string(array_agg(DISTINCT countries.name), '|'::text) AS names
   FROM ctgov.countries
  WHERE (countries.removed IS NOT TRUE)
  GROUP BY countries.nct_id;


--
-- Name: design_outcomes; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.design_outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    measure text,
    time_frame text,
    population character varying,
    description text
);


--
-- Name: all_design_outcomes; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_design_outcomes AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov.design_outcomes
  GROUP BY design_outcomes.nct_id;


--
-- Name: all_facilities; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_facilities AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(facilities.name), '|'::text) AS names
   FROM ctgov.facilities
  GROUP BY facilities.nct_id;


--
-- Name: design_groups; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.design_groups (
    id integer NOT NULL,
    nct_id character varying,
    group_type character varying,
    title character varying,
    description text
);


--
-- Name: all_group_types; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_group_types AS
 SELECT design_groups.nct_id,
    array_to_string(array_agg(DISTINCT design_groups.group_type), '|'::text) AS names
   FROM ctgov.design_groups
  GROUP BY design_groups.nct_id;


--
-- Name: id_information; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.id_information (
    id integer NOT NULL,
    nct_id character varying,
    id_source character varying,
    id_value character varying,
    id_type character varying,
    id_type_description character varying,
    id_link character varying
);


--
-- Name: all_id_information; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_id_information AS
 SELECT id_information.nct_id,
    array_to_string(array_agg(DISTINCT id_information.id_value), '|'::text) AS names
   FROM ctgov.id_information
  GROUP BY id_information.nct_id;


--
-- Name: interventions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.interventions (
    id integer NOT NULL,
    nct_id character varying,
    intervention_type character varying,
    name character varying,
    description text
);


--
-- Name: all_intervention_types; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_intervention_types AS
 SELECT interventions.nct_id,
    array_to_string(array_agg(interventions.intervention_type), '|'::text) AS names
   FROM ctgov.interventions
  GROUP BY interventions.nct_id;


--
-- Name: all_interventions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_interventions AS
 SELECT interventions.nct_id,
    array_to_string(array_agg(interventions.name), '|'::text) AS names
   FROM ctgov.interventions
  GROUP BY interventions.nct_id;


--
-- Name: keywords; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.keywords (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: all_keywords; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_keywords AS
 SELECT keywords.nct_id,
    array_to_string(array_agg(DISTINCT keywords.name), '|'::text) AS names
   FROM ctgov.keywords
  GROUP BY keywords.nct_id;


--
-- Name: overall_officials; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.overall_officials (
    id integer NOT NULL,
    nct_id character varying,
    role character varying,
    name character varying,
    affiliation character varying
);


--
-- Name: all_overall_official_affiliations; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_overall_official_affiliations AS
 SELECT overall_officials.nct_id,
    array_to_string(array_agg(overall_officials.affiliation), '|'::text) AS names
   FROM ctgov.overall_officials
  GROUP BY overall_officials.nct_id;


--
-- Name: all_overall_officials; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_overall_officials AS
 SELECT overall_officials.nct_id,
    array_to_string(array_agg(overall_officials.name), '|'::text) AS names
   FROM ctgov.overall_officials
  GROUP BY overall_officials.nct_id;


--
-- Name: all_primary_outcome_measures; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_primary_outcome_measures AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov.design_outcomes
  WHERE ((design_outcomes.outcome_type)::text = 'primary'::text)
  GROUP BY design_outcomes.nct_id;


--
-- Name: all_secondary_outcome_measures; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_secondary_outcome_measures AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov.design_outcomes
  WHERE ((design_outcomes.outcome_type)::text = 'secondary'::text)
  GROUP BY design_outcomes.nct_id;


--
-- Name: sponsors; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.sponsors (
    id integer NOT NULL,
    nct_id character varying,
    agency_class character varying,
    lead_or_collaborator character varying,
    name character varying
);


--
-- Name: all_sponsors; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_sponsors AS
 SELECT sponsors.nct_id,
    array_to_string(array_agg(DISTINCT sponsors.name), '|'::text) AS names
   FROM ctgov.sponsors
  GROUP BY sponsors.nct_id;


--
-- Name: all_states; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_states AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(DISTINCT facilities.state), '|'::text) AS names
   FROM ctgov.facilities
  GROUP BY facilities.nct_id;


--
-- Name: baseline_counts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.baseline_counts (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    units character varying,
    scope character varying,
    count integer
);


--
-- Name: baseline_counts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.baseline_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baseline_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.baseline_counts_id_seq OWNED BY ctgov.baseline_counts.id;


--
-- Name: baseline_measurements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.baseline_measurements (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    classification character varying,
    category character varying,
    title character varying,
    description text,
    units character varying,
    param_type character varying,
    param_value character varying,
    param_value_num numeric,
    dispersion_type character varying,
    dispersion_value character varying,
    dispersion_value_num numeric,
    dispersion_lower_limit numeric,
    dispersion_upper_limit numeric,
    explanation_of_na character varying
);


--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.baseline_measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.baseline_measurements_id_seq OWNED BY ctgov.baseline_measurements.id;


--
-- Name: brief_summaries; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.brief_summaries (
    id integer NOT NULL,
    nct_id character varying,
    description text
);


--
-- Name: brief_summaries_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.brief_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brief_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.brief_summaries_id_seq OWNED BY ctgov.brief_summaries.id;


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.browse_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.browse_conditions_id_seq OWNED BY ctgov.browse_conditions.id;


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.browse_interventions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.browse_interventions_id_seq OWNED BY ctgov.browse_interventions.id;


--
-- Name: calculated_values; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.calculated_values (
    id integer NOT NULL,
    nct_id character varying,
    number_of_facilities integer,
    number_of_nsae_subjects integer,
    number_of_sae_subjects integer,
    registered_in_calendar_year integer,
    nlm_download_date date,
    actual_duration integer,
    were_results_reported boolean DEFAULT false,
    months_to_report_results integer,
    has_us_facility boolean,
    has_single_facility boolean DEFAULT false,
    minimum_age_num integer,
    maximum_age_num integer,
    minimum_age_unit character varying,
    maximum_age_unit character varying,
    number_of_primary_outcomes_to_measure integer,
    number_of_secondary_outcomes_to_measure integer,
    number_of_other_outcomes_to_measure integer
);


--
-- Name: calculated_values_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.calculated_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calculated_values_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.calculated_values_id_seq OWNED BY ctgov.calculated_values.id;


--
-- Name: search_results; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.search_results (
    id integer NOT NULL,
    nct_id character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "grouping" character varying DEFAULT ''::character varying NOT NULL,
    study_search_id integer
);


--
-- Name: categories; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.categories AS
 SELECT search_results.id,
    search_results.nct_id,
    search_results.name,
    search_results.created_at,
    search_results.updated_at,
    search_results."grouping",
    search_results.study_search_id
   FROM ctgov.search_results;


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: central_contacts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.central_contacts (
    id integer NOT NULL,
    nct_id character varying,
    contact_type character varying,
    name character varying,
    phone character varying,
    email character varying,
    phone_extension character varying,
    role character varying
);


--
-- Name: central_contacts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.central_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: central_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.central_contacts_id_seq OWNED BY ctgov.central_contacts.id;


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.conditions_id_seq OWNED BY ctgov.conditions.id;


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.countries_id_seq OWNED BY ctgov.countries.id;


--
-- Name: designs; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.designs (
    id integer NOT NULL,
    nct_id character varying,
    allocation character varying,
    intervention_model character varying,
    observational_model character varying,
    primary_purpose character varying,
    time_perspective character varying,
    masking character varying,
    masking_description text,
    intervention_model_description text,
    subject_masked boolean,
    caregiver_masked boolean,
    investigator_masked boolean,
    outcomes_assessor_masked boolean
);


--
-- Name: detailed_descriptions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.detailed_descriptions (
    id integer NOT NULL,
    nct_id character varying,
    description text
);


--
-- Name: eligibilities; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.eligibilities (
    id integer NOT NULL,
    nct_id character varying,
    sampling_method character varying,
    gender character varying,
    minimum_age character varying,
    maximum_age character varying,
    healthy_volunteers character varying,
    population text,
    criteria text,
    gender_description text,
    gender_based boolean,
    adult boolean,
    child boolean,
    older_adult boolean
);


--
-- Name: studies; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.studies (
    nct_id character varying,
    nlm_download_date_description character varying,
    study_first_submitted_date date,
    results_first_submitted_date date,
    disposition_first_submitted_date date,
    last_update_submitted_date date,
    study_first_submitted_qc_date date,
    study_first_posted_date date,
    study_first_posted_date_type character varying,
    results_first_submitted_qc_date date,
    results_first_posted_date date,
    results_first_posted_date_type character varying,
    disposition_first_submitted_qc_date date,
    disposition_first_posted_date date,
    disposition_first_posted_date_type character varying,
    last_update_submitted_qc_date date,
    last_update_posted_date date,
    last_update_posted_date_type character varying,
    start_month_year character varying,
    start_date_type character varying,
    start_date date,
    verification_month_year character varying,
    verification_date date,
    completion_month_year character varying,
    completion_date_type character varying,
    completion_date date,
    primary_completion_month_year character varying,
    primary_completion_date_type character varying,
    primary_completion_date date,
    target_duration character varying,
    study_type character varying,
    acronym character varying,
    baseline_population text,
    brief_title text,
    official_title text,
    overall_status character varying,
    last_known_status character varying,
    phase character varying,
    enrollment integer,
    enrollment_type character varying,
    source character varying,
    limitations_and_caveats character varying,
    number_of_arms integer,
    number_of_groups integer,
    why_stopped character varying,
    has_expanded_access boolean,
    expanded_access_type_individual boolean,
    expanded_access_type_intermediate boolean,
    expanded_access_type_treatment boolean,
    has_dmc boolean,
    is_fda_regulated_drug boolean,
    is_fda_regulated_device boolean,
    is_unapproved_device boolean,
    is_ppsd boolean,
    is_us_export boolean,
    biospec_retention character varying,
    biospec_description text,
    ipd_time_frame character varying,
    ipd_access_criteria character varying,
    ipd_url character varying,
    plan_to_share_ipd character varying,
    plan_to_share_ipd_description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_class character varying,
    delayed_posting character varying,
    expanded_access_nctid character varying,
    expanded_access_status_for_nctid character varying,
    fdaaa801_violation boolean
);


--
-- Name: covid_19_studies; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.covid_19_studies AS
 SELECT s.nct_id,
    s.overall_status,
    s.study_type,
    s.official_title,
    s.acronym,
    s.phase,
    s.why_stopped,
    s.has_dmc,
    s.enrollment,
    s.is_fda_regulated_device,
    s.is_fda_regulated_drug,
    s.is_unapproved_device,
    s.has_expanded_access,
    s.study_first_submitted_date,
    s.last_update_posted_date,
    s.results_first_posted_date,
    s.start_date,
    s.primary_completion_date,
    s.completion_date,
    s.study_first_posted_date,
    cv.number_of_facilities,
    cv.has_single_facility,
    cv.nlm_download_date,
    s.number_of_arms,
    s.number_of_groups,
    sp.name AS lead_sponsor,
    aid.names AS other_ids,
    e.gender,
    e.gender_based,
    e.gender_description,
    e.population,
    e.minimum_age,
    e.maximum_age,
    e.criteria,
    e.healthy_volunteers,
    ak.names AS keywords,
    ai.names AS interventions,
    ac.names AS conditions,
    d.primary_purpose,
    d.allocation,
    d.observational_model,
    d.intervention_model,
    d.masking,
    d.subject_masked,
    d.caregiver_masked,
    d.investigator_masked,
    d.outcomes_assessor_masked,
    ado.names AS design_outcomes,
    bs.description AS brief_summary,
    dd.description AS detailed_description
   FROM (((((((((((ctgov.studies s
     FULL JOIN ctgov.all_conditions ac ON (((s.nct_id)::text = (ac.nct_id)::text)))
     FULL JOIN ctgov.all_id_information aid ON (((s.nct_id)::text = (aid.nct_id)::text)))
     FULL JOIN ctgov.all_design_outcomes ado ON (((s.nct_id)::text = (ado.nct_id)::text)))
     FULL JOIN ctgov.all_keywords ak ON (((s.nct_id)::text = (ak.nct_id)::text)))
     FULL JOIN ctgov.all_interventions ai ON (((s.nct_id)::text = (ai.nct_id)::text)))
     FULL JOIN ctgov.sponsors sp ON (((s.nct_id)::text = (sp.nct_id)::text)))
     FULL JOIN ctgov.calculated_values cv ON (((s.nct_id)::text = (cv.nct_id)::text)))
     FULL JOIN ctgov.designs d ON (((s.nct_id)::text = (d.nct_id)::text)))
     FULL JOIN ctgov.eligibilities e ON (((s.nct_id)::text = (e.nct_id)::text)))
     FULL JOIN ctgov.brief_summaries bs ON (((s.nct_id)::text = (bs.nct_id)::text)))
     FULL JOIN ctgov.detailed_descriptions dd ON (((s.nct_id)::text = (dd.nct_id)::text)))
  WHERE (((sp.lead_or_collaborator)::text = 'lead'::text) AND ((s.nct_id)::text IN ( SELECT search_results.nct_id
           FROM ctgov.search_results
          WHERE ((search_results.name)::text = 'covid-19'::text))));


--
-- Name: design_group_interventions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.design_group_interventions (
    id integer NOT NULL,
    nct_id character varying,
    design_group_id integer,
    intervention_id integer
);


--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.design_group_interventions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.design_group_interventions_id_seq OWNED BY ctgov.design_group_interventions.id;


--
-- Name: design_groups_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.design_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.design_groups_id_seq OWNED BY ctgov.design_groups.id;


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.design_outcomes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.design_outcomes_id_seq OWNED BY ctgov.design_outcomes.id;


--
-- Name: designs_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.designs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: designs_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.designs_id_seq OWNED BY ctgov.designs.id;


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.detailed_descriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.detailed_descriptions_id_seq OWNED BY ctgov.detailed_descriptions.id;


--
-- Name: documents; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.documents (
    id integer NOT NULL,
    nct_id character varying,
    document_id character varying,
    document_type character varying,
    url character varying,
    comment text
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.documents_id_seq OWNED BY ctgov.documents.id;


--
-- Name: drop_withdrawals; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.drop_withdrawals (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    period character varying,
    reason character varying,
    count integer
);


--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.drop_withdrawals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.drop_withdrawals_id_seq OWNED BY ctgov.drop_withdrawals.id;


--
-- Name: eligibilities_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.eligibilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eligibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.eligibilities_id_seq OWNED BY ctgov.eligibilities.id;


--
-- Name: facilities_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.facilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facilities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.facilities_id_seq OWNED BY ctgov.facilities.id;


--
-- Name: facility_contacts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.facility_contacts (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    contact_type character varying,
    name character varying,
    email character varying,
    phone character varying,
    phone_extension character varying
);


--
-- Name: facility_contacts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.facility_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.facility_contacts_id_seq OWNED BY ctgov.facility_contacts.id;


--
-- Name: facility_investigators; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.facility_investigators (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    role character varying,
    name character varying
);


--
-- Name: facility_investigators_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.facility_investigators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility_investigators_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.facility_investigators_id_seq OWNED BY ctgov.facility_investigators.id;


--
-- Name: file_records; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.file_records (
    id bigint NOT NULL,
    filename character varying,
    file_size bigint,
    file_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying
);


--
-- Name: file_records_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.file_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_records_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.file_records_id_seq OWNED BY ctgov.file_records.id;


--
-- Name: id_information_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.id_information_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: id_information_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.id_information_id_seq OWNED BY ctgov.id_information.id;


--
-- Name: intervention_other_names; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.intervention_other_names (
    id integer NOT NULL,
    nct_id character varying,
    intervention_id integer,
    name character varying
);


--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.intervention_other_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.intervention_other_names_id_seq OWNED BY ctgov.intervention_other_names.id;


--
-- Name: interventions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.interventions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.interventions_id_seq OWNED BY ctgov.interventions.id;


--
-- Name: ipd_information_types; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.ipd_information_types (
    id integer NOT NULL,
    nct_id character varying,
    name character varying
);


--
-- Name: ipd_information_types_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.ipd_information_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ipd_information_types_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.ipd_information_types_id_seq OWNED BY ctgov.ipd_information_types.id;


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.keywords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.keywords_id_seq OWNED BY ctgov.keywords.id;


--
-- Name: links; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.links (
    id integer NOT NULL,
    nct_id character varying,
    url character varying,
    description text
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.links_id_seq OWNED BY ctgov.links.id;


--
-- Name: mesh_headings; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.mesh_headings (
    id integer NOT NULL,
    qualifier character varying,
    heading character varying,
    subcategory character varying
);


--
-- Name: mesh_headings_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.mesh_headings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesh_headings_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.mesh_headings_id_seq OWNED BY ctgov.mesh_headings.id;


--
-- Name: mesh_terms; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.mesh_terms (
    id integer NOT NULL,
    qualifier character varying,
    tree_number character varying,
    description character varying,
    mesh_term character varying,
    downcase_mesh_term character varying
);


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.mesh_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.mesh_terms_id_seq OWNED BY ctgov.mesh_terms.id;


--
-- Name: milestones; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.milestones (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    title character varying,
    period character varying,
    description text,
    count integer
);


--
-- Name: milestones_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.milestones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: milestones_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.milestones_id_seq OWNED BY ctgov.milestones.id;


--
-- Name: outcome_analyses; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_analyses (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    non_inferiority_type character varying,
    non_inferiority_description text,
    param_type character varying,
    param_value numeric,
    dispersion_type character varying,
    dispersion_value numeric,
    p_value_modifier character varying,
    p_value double precision,
    ci_n_sides character varying,
    ci_percent numeric,
    ci_lower_limit numeric,
    ci_upper_limit numeric,
    ci_upper_limit_na_comment character varying,
    p_value_description character varying,
    method character varying,
    method_description text,
    estimate_description text,
    groups_description text,
    other_analysis_description text
);


--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_analyses_id_seq OWNED BY ctgov.outcome_analyses.id;


--
-- Name: outcome_analysis_groups; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_analysis_groups (
    id integer NOT NULL,
    nct_id character varying,
    outcome_analysis_id integer,
    result_group_id integer,
    ctgov_group_code character varying
);


--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_analysis_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_analysis_groups_id_seq OWNED BY ctgov.outcome_analysis_groups.id;


--
-- Name: outcome_counts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_counts (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_group_code character varying,
    scope character varying,
    units character varying,
    count integer
);


--
-- Name: outcome_counts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_counts_id_seq OWNED BY ctgov.outcome_counts.id;


--
-- Name: outcome_measurements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_measurements (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_group_code character varying,
    classification character varying,
    category character varying,
    title character varying,
    description text,
    units character varying,
    param_type character varying,
    param_value character varying,
    param_value_num numeric,
    dispersion_type character varying,
    dispersion_value character varying,
    dispersion_value_num numeric,
    dispersion_lower_limit numeric,
    dispersion_upper_limit numeric,
    explanation_of_na text
);


--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_measurements_id_seq OWNED BY ctgov.outcome_measurements.id;


--
-- Name: outcomes; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    title text,
    description text,
    time_frame text,
    population text,
    anticipated_posting_date date,
    anticipated_posting_month_year character varying,
    units character varying,
    units_analyzed character varying,
    dispersion_type character varying,
    param_type character varying
);


--
-- Name: outcomes_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcomes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcomes_id_seq OWNED BY ctgov.outcomes.id;


--
-- Name: overall_officials_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.overall_officials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: overall_officials_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.overall_officials_id_seq OWNED BY ctgov.overall_officials.id;


--
-- Name: participant_flows; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.participant_flows (
    id integer NOT NULL,
    nct_id character varying,
    recruitment_details text,
    pre_assignment_details text,
    units_analyzed character varying
);


--
-- Name: participant_flows_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.participant_flows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participant_flows_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.participant_flows_id_seq OWNED BY ctgov.participant_flows.id;


--
-- Name: pending_results; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.pending_results (
    id integer NOT NULL,
    nct_id character varying,
    event character varying,
    event_date_description character varying,
    event_date date
);


--
-- Name: pending_results_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.pending_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pending_results_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.pending_results_id_seq OWNED BY ctgov.pending_results.id;


--
-- Name: provided_documents; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.provided_documents (
    id integer NOT NULL,
    nct_id character varying,
    document_type character varying,
    has_protocol boolean,
    has_icf boolean,
    has_sap boolean,
    document_date date,
    url character varying
);


--
-- Name: provided_documents_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.provided_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provided_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.provided_documents_id_seq OWNED BY ctgov.provided_documents.id;


--
-- Name: reported_event_totals; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.reported_event_totals (
    id integer NOT NULL,
    nct_id character varying NOT NULL,
    ctgov_group_code character varying NOT NULL,
    event_type character varying,
    classification character varying NOT NULL,
    subjects_affected integer,
    subjects_at_risk integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reported_event_totals_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.reported_event_totals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reported_event_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.reported_event_totals_id_seq OWNED BY ctgov.reported_event_totals.id;


--
-- Name: reported_events; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.reported_events (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    time_frame text,
    event_type character varying,
    default_vocab character varying,
    default_assessment character varying,
    subjects_affected integer,
    subjects_at_risk integer,
    description text,
    event_count integer,
    organ_system character varying,
    adverse_event_term character varying,
    frequency_threshold integer,
    vocab character varying,
    assessment character varying
);


--
-- Name: reported_events_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.reported_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reported_events_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.reported_events_id_seq OWNED BY ctgov.reported_events.id;


--
-- Name: responsible_parties; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.responsible_parties (
    id integer NOT NULL,
    nct_id character varying,
    responsible_party_type character varying,
    name character varying,
    title character varying,
    organization character varying,
    affiliation text,
    old_name_title character varying
);


--
-- Name: responsible_parties_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.responsible_parties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responsible_parties_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.responsible_parties_id_seq OWNED BY ctgov.responsible_parties.id;


--
-- Name: result_agreements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.result_agreements (
    id integer NOT NULL,
    nct_id character varying,
    pi_employee character varying,
    agreement text,
    restriction_type character varying,
    other_details text,
    restrictive_agreement character varying
);


--
-- Name: result_agreements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.result_agreements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.result_agreements_id_seq OWNED BY ctgov.result_agreements.id;


--
-- Name: result_contacts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.result_contacts (
    id integer NOT NULL,
    nct_id character varying,
    organization character varying,
    name character varying,
    phone character varying,
    email character varying,
    extension character varying
);


--
-- Name: result_contacts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.result_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.result_contacts_id_seq OWNED BY ctgov.result_contacts.id;


--
-- Name: result_groups; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.result_groups (
    id integer NOT NULL,
    nct_id character varying,
    ctgov_group_code character varying,
    result_type character varying,
    title character varying,
    description text
);


--
-- Name: result_groups_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.result_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.result_groups_id_seq OWNED BY ctgov.result_groups.id;


--
-- Name: retractions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.retractions (
    id bigint NOT NULL,
    reference_id integer,
    pmid character varying,
    source character varying,
    nct_id character varying
);


--
-- Name: retractions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.retractions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: retractions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.retractions_id_seq OWNED BY ctgov.retractions.id;


--
-- Name: search_results_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.search_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_results_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.search_results_id_seq OWNED BY ctgov.search_results.id;


--
-- Name: sponsors_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.sponsors_id_seq OWNED BY ctgov.sponsors.id;


--
-- Name: study_references; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.study_references (
    id integer NOT NULL,
    nct_id character varying,
    pmid character varying,
    reference_type character varying,
    citation text
);


--
-- Name: study_references_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.study_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_references_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.study_references_id_seq OWNED BY ctgov.study_references.id;


--
-- Name: study_searches; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.study_searches (
    id integer NOT NULL,
    save_tsv boolean DEFAULT false NOT NULL,
    query character varying NOT NULL,
    "grouping" character varying DEFAULT ''::character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    beta_api boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_searches_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.study_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.study_searches_id_seq OWNED BY ctgov.study_searches.id;


--
-- Name: verifiers; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.verifiers (
    id bigint NOT NULL,
    differences json DEFAULT '[]'::json NOT NULL,
    last_run timestamp without time zone,
    source json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    load_event_id integer
);


--
-- Name: verifiers_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.verifiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: verifiers_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.verifiers_id_seq OWNED BY ctgov.verifiers.id;


--
-- Name: authors; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.authors (
    id bigint NOT NULL,
    qcode character varying,
    types character varying,
    name character varying,
    downcase_name character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.authors_id_seq OWNED BY lookup.authors.id;


--
-- Name: conditions; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.conditions (
    id bigint NOT NULL,
    qcode character varying,
    types character varying,
    preferred_name character varying,
    name character varying,
    downcase_name character varying,
    lookup character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.conditions_id_seq OWNED BY lookup.conditions.id;


--
-- Name: countries; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.countries (
    id bigint NOT NULL,
    qcode character varying,
    types character varying,
    name character varying,
    downcase_name character varying,
    iso2 character varying,
    osm_relid character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.countries_id_seq OWNED BY lookup.countries.id;


--
-- Name: interventions; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.interventions (
    id bigint NOT NULL,
    qcode character varying,
    types character varying,
    preferred_name character varying,
    name character varying,
    downcase_name character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: interventions_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.interventions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.interventions_id_seq OWNED BY lookup.interventions.id;


--
-- Name: journals; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.journals (
    id bigint NOT NULL,
    qcode character varying,
    types character varying,
    name character varying,
    downcase_name character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: journals_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journals_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.journals_id_seq OWNED BY lookup.journals.id;


--
-- Name: keywords; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.keywords (
    id bigint NOT NULL,
    qcode character varying,
    preferred_name character varying,
    name character varying,
    types character varying,
    downcase_name character varying,
    lookup character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.keywords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.keywords_id_seq OWNED BY lookup.keywords.id;


--
-- Name: organizations; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.organizations (
    id bigint NOT NULL,
    preferred_name character varying,
    qcode character varying,
    types character varying,
    name character varying,
    downcase_name character varying,
    wiki_description character varying,
    qs_world_univ_id character varying,
    arwu_univ_id character varying,
    times_higher_ed_id character varying,
    grid_id character varying,
    country character varying,
    looks_suspicious character varying
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.organizations_id_seq OWNED BY lookup.organizations.id;


--
-- Name: publications; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.publications (
    id bigint NOT NULL,
    qcode character varying,
    min_or_max character varying,
    preferred_name character varying,
    name character varying,
    downcase_name character varying,
    pmid character varying,
    lookup character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.publications_id_seq OWNED BY lookup.publications.id;


--
-- Name: sponsors; Type: TABLE; Schema: lookup; Owner: -
--

CREATE TABLE lookup.sponsors (
    id bigint NOT NULL,
    preferred_name character varying,
    qcode character varying,
    types character varying,
    name character varying,
    downcase_name character varying,
    wiki_description character varying,
    looks_suspicious character varying
);


--
-- Name: sponsors_id_seq; Type: SEQUENCE; Schema: lookup; Owner: -
--

CREATE SEQUENCE lookup.sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: lookup; Owner: -
--

ALTER SEQUENCE lookup.sponsors_id_seq OWNED BY lookup.sponsors.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: author_affiliations; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.author_affiliations (
    id bigint NOT NULL,
    "pubmed.author_id" bigint,
    pmid character varying,
    qcode character varying,
    isni character varying,
    grid character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: author_affiliations_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.author_affiliations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: author_affiliations_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.author_affiliations_id_seq OWNED BY pubmed.author_affiliations.id;


--
-- Name: authors; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.authors (
    id bigint NOT NULL,
    "pubmed.publication_id" bigint,
    pmid character varying,
    qcode character varying,
    orcid character varying,
    validated boolean,
    last_name character varying,
    first_name character varying,
    initials character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.authors_id_seq OWNED BY pubmed.authors.id;


--
-- Name: chemicals; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.chemicals (
    id bigint NOT NULL,
    pmid character varying,
    registry_number character varying,
    ui character varying,
    name character varying
);


--
-- Name: chemicals_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.chemicals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chemicals_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.chemicals_id_seq OWNED BY pubmed.chemicals.id;


--
-- Name: grants; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.grants (
    id bigint NOT NULL,
    pmid character varying,
    grant_id character varying,
    acronym character varying,
    agency character varying,
    country character varying,
    country_qcode character varying
);


--
-- Name: grants_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grants_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.grants_id_seq OWNED BY pubmed.grants.id;


--
-- Name: mesh_terms; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.mesh_terms (
    id bigint NOT NULL,
    pmid character varying,
    ui character varying,
    name character varying,
    major_topic boolean,
    qualifier_name character varying,
    qualifier_ui character varying,
    qualifier_major_topic character varying
);


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.mesh_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.mesh_terms_id_seq OWNED BY pubmed.mesh_terms.id;


--
-- Name: other_ids; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.other_ids (
    id bigint NOT NULL,
    pmid character varying,
    id_type character varying,
    id_value character varying
);


--
-- Name: other_ids_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.other_ids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: other_ids_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.other_ids_id_seq OWNED BY pubmed.other_ids.id;


--
-- Name: publications; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.publications (
    id bigint NOT NULL,
    pmid character varying,
    issn character varying,
    volume character varying,
    issue character varying,
    iso_abbreviation character varying,
    published_in character varying,
    completion_date date,
    revision_date date,
    publication_date date,
    publication_date_str character varying,
    publication_year integer,
    publication_month integer,
    publication_day integer,
    title character varying,
    pagination character varying,
    abstract character varying,
    country character varying,
    country_qcode character varying,
    language character varying,
    medline_ta character varying,
    nlm_unique_id character varying,
    issn_linking character varying,
    journal_qcode character varying,
    name character varying
);


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.publications_id_seq OWNED BY pubmed.publications.id;


--
-- Name: types; Type: TABLE; Schema: pubmed; Owner: -
--

CREATE TABLE pubmed.types (
    id bigint NOT NULL,
    pmid character varying,
    ui character varying,
    name character varying
);


--
-- Name: types_id_seq; Type: SEQUENCE; Schema: pubmed; Owner: -
--

CREATE SEQUENCE pubmed.types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: pubmed; Owner: -
--

ALTER SEQUENCE pubmed.types_id_seq OWNED BY pubmed.types.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('ctgov.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('ctgov.active_storage_blobs_id_seq'::regclass);


--
-- Name: baseline_counts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_counts ALTER COLUMN id SET DEFAULT nextval('ctgov.baseline_counts_id_seq'::regclass);


--
-- Name: baseline_measurements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_measurements ALTER COLUMN id SET DEFAULT nextval('ctgov.baseline_measurements_id_seq'::regclass);


--
-- Name: brief_summaries id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.brief_summaries ALTER COLUMN id SET DEFAULT nextval('ctgov.brief_summaries_id_seq'::regclass);


--
-- Name: browse_conditions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_conditions ALTER COLUMN id SET DEFAULT nextval('ctgov.browse_conditions_id_seq'::regclass);


--
-- Name: browse_interventions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_interventions ALTER COLUMN id SET DEFAULT nextval('ctgov.browse_interventions_id_seq'::regclass);


--
-- Name: calculated_values id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.calculated_values ALTER COLUMN id SET DEFAULT nextval('ctgov.calculated_values_id_seq'::regclass);


--
-- Name: central_contacts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.central_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov.central_contacts_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.conditions ALTER COLUMN id SET DEFAULT nextval('ctgov.conditions_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.countries ALTER COLUMN id SET DEFAULT nextval('ctgov.countries_id_seq'::regclass);


--
-- Name: design_group_interventions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_group_interventions ALTER COLUMN id SET DEFAULT nextval('ctgov.design_group_interventions_id_seq'::regclass);


--
-- Name: design_groups id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_groups ALTER COLUMN id SET DEFAULT nextval('ctgov.design_groups_id_seq'::regclass);


--
-- Name: design_outcomes id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_outcomes ALTER COLUMN id SET DEFAULT nextval('ctgov.design_outcomes_id_seq'::regclass);


--
-- Name: designs id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.designs ALTER COLUMN id SET DEFAULT nextval('ctgov.designs_id_seq'::regclass);


--
-- Name: detailed_descriptions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.detailed_descriptions ALTER COLUMN id SET DEFAULT nextval('ctgov.detailed_descriptions_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.documents ALTER COLUMN id SET DEFAULT nextval('ctgov.documents_id_seq'::regclass);


--
-- Name: drop_withdrawals id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.drop_withdrawals ALTER COLUMN id SET DEFAULT nextval('ctgov.drop_withdrawals_id_seq'::regclass);


--
-- Name: eligibilities id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.eligibilities ALTER COLUMN id SET DEFAULT nextval('ctgov.eligibilities_id_seq'::regclass);


--
-- Name: facilities id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facilities ALTER COLUMN id SET DEFAULT nextval('ctgov.facilities_id_seq'::regclass);


--
-- Name: facility_contacts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov.facility_contacts_id_seq'::regclass);


--
-- Name: facility_investigators id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_investigators ALTER COLUMN id SET DEFAULT nextval('ctgov.facility_investigators_id_seq'::regclass);


--
-- Name: file_records id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.file_records ALTER COLUMN id SET DEFAULT nextval('ctgov.file_records_id_seq'::regclass);


--
-- Name: id_information id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.id_information ALTER COLUMN id SET DEFAULT nextval('ctgov.id_information_id_seq'::regclass);


--
-- Name: intervention_other_names id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.intervention_other_names ALTER COLUMN id SET DEFAULT nextval('ctgov.intervention_other_names_id_seq'::regclass);


--
-- Name: interventions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.interventions ALTER COLUMN id SET DEFAULT nextval('ctgov.interventions_id_seq'::regclass);


--
-- Name: ipd_information_types id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.ipd_information_types ALTER COLUMN id SET DEFAULT nextval('ctgov.ipd_information_types_id_seq'::regclass);


--
-- Name: keywords id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.keywords ALTER COLUMN id SET DEFAULT nextval('ctgov.keywords_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.links ALTER COLUMN id SET DEFAULT nextval('ctgov.links_id_seq'::regclass);


--
-- Name: mesh_headings id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_headings ALTER COLUMN id SET DEFAULT nextval('ctgov.mesh_headings_id_seq'::regclass);


--
-- Name: mesh_terms id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_terms ALTER COLUMN id SET DEFAULT nextval('ctgov.mesh_terms_id_seq'::regclass);


--
-- Name: milestones id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.milestones ALTER COLUMN id SET DEFAULT nextval('ctgov.milestones_id_seq'::regclass);


--
-- Name: outcome_analyses id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analyses ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_analyses_id_seq'::regclass);


--
-- Name: outcome_analysis_groups id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analysis_groups ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_analysis_groups_id_seq'::regclass);


--
-- Name: outcome_counts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_counts ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_counts_id_seq'::regclass);


--
-- Name: outcome_measurements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_measurements ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_measurements_id_seq'::regclass);


--
-- Name: outcomes id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcomes ALTER COLUMN id SET DEFAULT nextval('ctgov.outcomes_id_seq'::regclass);


--
-- Name: overall_officials id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.overall_officials ALTER COLUMN id SET DEFAULT nextval('ctgov.overall_officials_id_seq'::regclass);


--
-- Name: participant_flows id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.participant_flows ALTER COLUMN id SET DEFAULT nextval('ctgov.participant_flows_id_seq'::regclass);


--
-- Name: pending_results id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.pending_results ALTER COLUMN id SET DEFAULT nextval('ctgov.pending_results_id_seq'::regclass);


--
-- Name: provided_documents id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.provided_documents ALTER COLUMN id SET DEFAULT nextval('ctgov.provided_documents_id_seq'::regclass);


--
-- Name: reported_event_totals id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_event_totals ALTER COLUMN id SET DEFAULT nextval('ctgov.reported_event_totals_id_seq'::regclass);


--
-- Name: reported_events id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_events ALTER COLUMN id SET DEFAULT nextval('ctgov.reported_events_id_seq'::regclass);


--
-- Name: responsible_parties id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.responsible_parties ALTER COLUMN id SET DEFAULT nextval('ctgov.responsible_parties_id_seq'::regclass);


--
-- Name: result_agreements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_agreements ALTER COLUMN id SET DEFAULT nextval('ctgov.result_agreements_id_seq'::regclass);


--
-- Name: result_contacts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov.result_contacts_id_seq'::regclass);


--
-- Name: result_groups id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_groups ALTER COLUMN id SET DEFAULT nextval('ctgov.result_groups_id_seq'::regclass);


--
-- Name: retractions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.retractions ALTER COLUMN id SET DEFAULT nextval('ctgov.retractions_id_seq'::regclass);


--
-- Name: search_results id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_results ALTER COLUMN id SET DEFAULT nextval('ctgov.search_results_id_seq'::regclass);


--
-- Name: sponsors id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.sponsors ALTER COLUMN id SET DEFAULT nextval('ctgov.sponsors_id_seq'::regclass);


--
-- Name: study_references id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_references ALTER COLUMN id SET DEFAULT nextval('ctgov.study_references_id_seq'::regclass);


--
-- Name: study_searches id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_searches ALTER COLUMN id SET DEFAULT nextval('ctgov.study_searches_id_seq'::regclass);


--
-- Name: verifiers id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.verifiers ALTER COLUMN id SET DEFAULT nextval('ctgov.verifiers_id_seq'::regclass);


--
-- Name: authors id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.authors ALTER COLUMN id SET DEFAULT nextval('lookup.authors_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.conditions ALTER COLUMN id SET DEFAULT nextval('lookup.conditions_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.countries ALTER COLUMN id SET DEFAULT nextval('lookup.countries_id_seq'::regclass);


--
-- Name: interventions id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.interventions ALTER COLUMN id SET DEFAULT nextval('lookup.interventions_id_seq'::regclass);


--
-- Name: journals id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.journals ALTER COLUMN id SET DEFAULT nextval('lookup.journals_id_seq'::regclass);


--
-- Name: keywords id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.keywords ALTER COLUMN id SET DEFAULT nextval('lookup.keywords_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.organizations ALTER COLUMN id SET DEFAULT nextval('lookup.organizations_id_seq'::regclass);


--
-- Name: publications id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.publications ALTER COLUMN id SET DEFAULT nextval('lookup.publications_id_seq'::regclass);


--
-- Name: sponsors id; Type: DEFAULT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.sponsors ALTER COLUMN id SET DEFAULT nextval('lookup.sponsors_id_seq'::regclass);


--
-- Name: author_affiliations id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.author_affiliations ALTER COLUMN id SET DEFAULT nextval('pubmed.author_affiliations_id_seq'::regclass);


--
-- Name: authors id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.authors ALTER COLUMN id SET DEFAULT nextval('pubmed.authors_id_seq'::regclass);


--
-- Name: chemicals id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.chemicals ALTER COLUMN id SET DEFAULT nextval('pubmed.chemicals_id_seq'::regclass);


--
-- Name: grants id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.grants ALTER COLUMN id SET DEFAULT nextval('pubmed.grants_id_seq'::regclass);


--
-- Name: mesh_terms id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.mesh_terms ALTER COLUMN id SET DEFAULT nextval('pubmed.mesh_terms_id_seq'::regclass);


--
-- Name: other_ids id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.other_ids ALTER COLUMN id SET DEFAULT nextval('pubmed.other_ids_id_seq'::regclass);


--
-- Name: publications id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.publications ALTER COLUMN id SET DEFAULT nextval('pubmed.publications_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.types ALTER COLUMN id SET DEFAULT nextval('pubmed.types_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: baseline_counts baseline_counts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_counts
    ADD CONSTRAINT baseline_counts_pkey PRIMARY KEY (id);


--
-- Name: baseline_measurements baseline_measurements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_measurements
    ADD CONSTRAINT baseline_measurements_pkey PRIMARY KEY (id);


--
-- Name: brief_summaries brief_summaries_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.brief_summaries
    ADD CONSTRAINT brief_summaries_pkey PRIMARY KEY (id);


--
-- Name: browse_conditions browse_conditions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_conditions
    ADD CONSTRAINT browse_conditions_pkey PRIMARY KEY (id);


--
-- Name: browse_interventions browse_interventions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_interventions
    ADD CONSTRAINT browse_interventions_pkey PRIMARY KEY (id);


--
-- Name: calculated_values calculated_values_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.calculated_values
    ADD CONSTRAINT calculated_values_pkey PRIMARY KEY (id);


--
-- Name: central_contacts central_contacts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.central_contacts
    ADD CONSTRAINT central_contacts_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: design_group_interventions design_group_interventions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_group_interventions
    ADD CONSTRAINT design_group_interventions_pkey PRIMARY KEY (id);


--
-- Name: design_groups design_groups_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_groups
    ADD CONSTRAINT design_groups_pkey PRIMARY KEY (id);


--
-- Name: design_outcomes design_outcomes_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_outcomes
    ADD CONSTRAINT design_outcomes_pkey PRIMARY KEY (id);


--
-- Name: designs designs_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.designs
    ADD CONSTRAINT designs_pkey PRIMARY KEY (id);


--
-- Name: detailed_descriptions detailed_descriptions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.detailed_descriptions
    ADD CONSTRAINT detailed_descriptions_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: drop_withdrawals drop_withdrawals_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.drop_withdrawals
    ADD CONSTRAINT drop_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: eligibilities eligibilities_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.eligibilities
    ADD CONSTRAINT eligibilities_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_contacts facility_contacts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_contacts
    ADD CONSTRAINT facility_contacts_pkey PRIMARY KEY (id);


--
-- Name: facility_investigators facility_investigators_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_investigators
    ADD CONSTRAINT facility_investigators_pkey PRIMARY KEY (id);


--
-- Name: file_records file_records_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.file_records
    ADD CONSTRAINT file_records_pkey PRIMARY KEY (id);


--
-- Name: id_information id_information_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.id_information
    ADD CONSTRAINT id_information_pkey PRIMARY KEY (id);


--
-- Name: intervention_other_names intervention_other_names_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.intervention_other_names
    ADD CONSTRAINT intervention_other_names_pkey PRIMARY KEY (id);


--
-- Name: interventions interventions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.interventions
    ADD CONSTRAINT interventions_pkey PRIMARY KEY (id);


--
-- Name: ipd_information_types ipd_information_types_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.ipd_information_types
    ADD CONSTRAINT ipd_information_types_pkey PRIMARY KEY (id);


--
-- Name: keywords keywords_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: mesh_headings mesh_headings_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_headings
    ADD CONSTRAINT mesh_headings_pkey PRIMARY KEY (id);


--
-- Name: mesh_terms mesh_terms_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_terms
    ADD CONSTRAINT mesh_terms_pkey PRIMARY KEY (id);


--
-- Name: milestones milestones_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: outcome_analyses outcome_analyses_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analyses
    ADD CONSTRAINT outcome_analyses_pkey PRIMARY KEY (id);


--
-- Name: outcome_analysis_groups outcome_analysis_groups_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analysis_groups
    ADD CONSTRAINT outcome_analysis_groups_pkey PRIMARY KEY (id);


--
-- Name: outcome_counts outcome_counts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_counts
    ADD CONSTRAINT outcome_counts_pkey PRIMARY KEY (id);


--
-- Name: outcome_measurements outcome_measurements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_measurements
    ADD CONSTRAINT outcome_measurements_pkey PRIMARY KEY (id);


--
-- Name: outcomes outcomes_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcomes
    ADD CONSTRAINT outcomes_pkey PRIMARY KEY (id);


--
-- Name: overall_officials overall_officials_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.overall_officials
    ADD CONSTRAINT overall_officials_pkey PRIMARY KEY (id);


--
-- Name: participant_flows participant_flows_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.participant_flows
    ADD CONSTRAINT participant_flows_pkey PRIMARY KEY (id);


--
-- Name: pending_results pending_results_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.pending_results
    ADD CONSTRAINT pending_results_pkey PRIMARY KEY (id);


--
-- Name: provided_documents provided_documents_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.provided_documents
    ADD CONSTRAINT provided_documents_pkey PRIMARY KEY (id);


--
-- Name: reported_event_totals reported_event_totals_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_event_totals
    ADD CONSTRAINT reported_event_totals_pkey PRIMARY KEY (id);


--
-- Name: reported_events reported_events_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_events
    ADD CONSTRAINT reported_events_pkey PRIMARY KEY (id);


--
-- Name: responsible_parties responsible_parties_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.responsible_parties
    ADD CONSTRAINT responsible_parties_pkey PRIMARY KEY (id);


--
-- Name: result_agreements result_agreements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_agreements
    ADD CONSTRAINT result_agreements_pkey PRIMARY KEY (id);


--
-- Name: result_contacts result_contacts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_contacts
    ADD CONSTRAINT result_contacts_pkey PRIMARY KEY (id);


--
-- Name: result_groups result_groups_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_groups
    ADD CONSTRAINT result_groups_pkey PRIMARY KEY (id);


--
-- Name: retractions retractions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.retractions
    ADD CONSTRAINT retractions_pkey PRIMARY KEY (id);


--
-- Name: search_results search_results_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_results
    ADD CONSTRAINT search_results_pkey PRIMARY KEY (id);


--
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);


--
-- Name: study_references study_references_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_references
    ADD CONSTRAINT study_references_pkey PRIMARY KEY (id);


--
-- Name: study_searches study_searches_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_searches
    ADD CONSTRAINT study_searches_pkey PRIMARY KEY (id);


--
-- Name: verifiers verifiers_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.verifiers
    ADD CONSTRAINT verifiers_pkey PRIMARY KEY (id);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: interventions interventions_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.interventions
    ADD CONSTRAINT interventions_pkey PRIMARY KEY (id);


--
-- Name: journals journals_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.journals
    ADD CONSTRAINT journals_pkey PRIMARY KEY (id);


--
-- Name: keywords keywords_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: lookup; Owner: -
--

ALTER TABLE ONLY lookup.sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: author_affiliations author_affiliations_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.author_affiliations
    ADD CONSTRAINT author_affiliations_pkey PRIMARY KEY (id);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: chemicals chemicals_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.chemicals
    ADD CONSTRAINT chemicals_pkey PRIMARY KEY (id);


--
-- Name: grants grants_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.grants
    ADD CONSTRAINT grants_pkey PRIMARY KEY (id);


--
-- Name: mesh_terms mesh_terms_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.mesh_terms
    ADD CONSTRAINT mesh_terms_pkey PRIMARY KEY (id);


--
-- Name: other_ids other_ids_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.other_ids
    ADD CONSTRAINT other_ids_pkey PRIMARY KEY (id);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: pubmed; Owner: -
--

ALTER TABLE ONLY pubmed.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: baseline_counts_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX baseline_counts_nct_idx ON ctgov.baseline_counts USING btree (nct_id);


--
-- Name: baseline_measurements_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX baseline_measurements_nct_idx ON ctgov.baseline_measurements USING btree (nct_id);


--
-- Name: brief_summaries_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX brief_summaries_nct_idx ON ctgov.brief_summaries USING btree (nct_id);


--
-- Name: browse_conditions_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX browse_conditions_nct_idx ON ctgov.browse_conditions USING btree (nct_id);


--
-- Name: browse_interventions_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX browse_interventions_nct_idx ON ctgov.browse_interventions USING btree (nct_id);


--
-- Name: calculated_values_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX calculated_values_nct_idx ON ctgov.calculated_values USING btree (nct_id);


--
-- Name: categories_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX categories_nct_idx ON ctgov.search_results USING btree (nct_id);


--
-- Name: central_contacts_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX central_contacts_nct_idx ON ctgov.central_contacts USING btree (nct_id);


--
-- Name: conditions_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX conditions_nct_idx ON ctgov.conditions USING btree (nct_id);


--
-- Name: countries_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX countries_nct_idx ON ctgov.countries USING btree (nct_id);


--
-- Name: design_group_interventions_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX design_group_interventions_nct_idx ON ctgov.design_group_interventions USING btree (nct_id);


--
-- Name: design_groups_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX design_groups_nct_idx ON ctgov.design_groups USING btree (nct_id);


--
-- Name: design_outcomes_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX design_outcomes_nct_idx ON ctgov.design_outcomes USING btree (nct_id);


--
-- Name: designs_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX designs_nct_idx ON ctgov.designs USING btree (nct_id);


--
-- Name: detailed_descriptions_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX detailed_descriptions_nct_idx ON ctgov.detailed_descriptions USING btree (nct_id);


--
-- Name: documents_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX documents_nct_idx ON ctgov.documents USING btree (nct_id);


--
-- Name: drop_withdrawals_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX drop_withdrawals_nct_idx ON ctgov.drop_withdrawals USING btree (nct_id);


--
-- Name: eligibilities_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX eligibilities_nct_idx ON ctgov.eligibilities USING btree (nct_id);


--
-- Name: facilities_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX facilities_nct_idx ON ctgov.facilities USING btree (nct_id);


--
-- Name: facility_contacts_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX facility_contacts_nct_idx ON ctgov.facility_contacts USING btree (nct_id);


--
-- Name: facility_investigators_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX facility_investigators_nct_idx ON ctgov.facility_investigators USING btree (nct_id);


--
-- Name: id_information_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX id_information_nct_idx ON ctgov.id_information USING btree (nct_id);


--
-- Name: index_baseline_counts_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_baseline_counts_on_nct_id ON ctgov.baseline_counts USING btree (nct_id);


--
-- Name: index_baseline_measurements_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_baseline_measurements_on_nct_id ON ctgov.baseline_measurements USING btree (nct_id);


--
-- Name: index_brief_summaries_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_brief_summaries_on_nct_id ON ctgov.brief_summaries USING btree (nct_id);


--
-- Name: index_browse_conditions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_conditions_on_nct_id ON ctgov.browse_conditions USING btree (nct_id);


--
-- Name: index_browse_interventions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_interventions_on_nct_id ON ctgov.browse_interventions USING btree (nct_id);


--
-- Name: index_calculated_values_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_calculated_values_on_nct_id ON ctgov.calculated_values USING btree (nct_id);


--
-- Name: index_central_contacts_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_central_contacts_on_nct_id ON ctgov.central_contacts USING btree (nct_id);


--
-- Name: index_conditions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_conditions_on_nct_id ON ctgov.conditions USING btree (nct_id);


--
-- Name: index_countries_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_countries_on_nct_id ON ctgov.countries USING btree (nct_id);


--
-- Name: index_design_group_interventions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_group_interventions_on_nct_id ON ctgov.design_group_interventions USING btree (nct_id);


--
-- Name: index_design_groups_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_groups_on_nct_id ON ctgov.design_groups USING btree (nct_id);


--
-- Name: index_design_outcomes_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_outcomes_on_nct_id ON ctgov.design_outcomes USING btree (nct_id);


--
-- Name: index_designs_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_designs_on_nct_id ON ctgov.designs USING btree (nct_id);


--
-- Name: index_detailed_descriptions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_detailed_descriptions_on_nct_id ON ctgov.detailed_descriptions USING btree (nct_id);


--
-- Name: index_documents_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_documents_on_nct_id ON ctgov.documents USING btree (nct_id);


--
-- Name: index_drop_withdrawals_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_drop_withdrawals_on_nct_id ON ctgov.drop_withdrawals USING btree (nct_id);


--
-- Name: index_eligibilities_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_eligibilities_on_nct_id ON ctgov.eligibilities USING btree (nct_id);


--
-- Name: index_facilities_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facilities_on_nct_id ON ctgov.facilities USING btree (nct_id);


--
-- Name: index_facility_contacts_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facility_contacts_on_nct_id ON ctgov.facility_contacts USING btree (nct_id);


--
-- Name: index_facility_investigators_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facility_investigators_on_nct_id ON ctgov.facility_investigators USING btree (nct_id);


--
-- Name: index_id_information_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_id_information_on_nct_id ON ctgov.id_information USING btree (nct_id);


--
-- Name: index_intervention_other_names_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_intervention_other_names_on_nct_id ON ctgov.intervention_other_names USING btree (nct_id);


--
-- Name: index_interventions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_interventions_on_nct_id ON ctgov.interventions USING btree (nct_id);


--
-- Name: index_ipd_information_types_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_ipd_information_types_on_nct_id ON ctgov.ipd_information_types USING btree (nct_id);


--
-- Name: index_keywords_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_keywords_on_nct_id ON ctgov.keywords USING btree (nct_id);


--
-- Name: index_links_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_links_on_nct_id ON ctgov.links USING btree (nct_id);


--
-- Name: index_mesh_headings_on_qualifier; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_headings_on_qualifier ON ctgov.mesh_headings USING btree (qualifier);


--
-- Name: index_mesh_terms_on_description; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_description ON ctgov.mesh_terms USING btree (description);


--
-- Name: index_mesh_terms_on_downcase_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_downcase_mesh_term ON ctgov.mesh_terms USING btree (downcase_mesh_term);


--
-- Name: index_mesh_terms_on_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_mesh_term ON ctgov.mesh_terms USING btree (mesh_term);


--
-- Name: index_mesh_terms_on_qualifier; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_qualifier ON ctgov.mesh_terms USING btree (qualifier);


--
-- Name: index_milestones_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_milestones_on_nct_id ON ctgov.milestones USING btree (nct_id);


--
-- Name: index_outcome_analyses_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_analyses_on_nct_id ON ctgov.outcome_analyses USING btree (nct_id);


--
-- Name: index_outcome_analysis_groups_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_analysis_groups_on_nct_id ON ctgov.outcome_analysis_groups USING btree (nct_id);


--
-- Name: index_outcome_counts_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_counts_on_nct_id ON ctgov.outcome_counts USING btree (nct_id);


--
-- Name: index_outcome_measurements_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_measurements_on_nct_id ON ctgov.outcome_measurements USING btree (nct_id);


--
-- Name: index_outcomes_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcomes_on_nct_id ON ctgov.outcomes USING btree (nct_id);


--
-- Name: index_overall_officials_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_overall_officials_on_nct_id ON ctgov.overall_officials USING btree (nct_id);


--
-- Name: index_participant_flows_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_participant_flows_on_nct_id ON ctgov.participant_flows USING btree (nct_id);


--
-- Name: index_pending_results_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_pending_results_on_nct_id ON ctgov.pending_results USING btree (nct_id);


--
-- Name: index_provided_documents_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_provided_documents_on_nct_id ON ctgov.provided_documents USING btree (nct_id);


--
-- Name: index_reported_event_totals_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_reported_event_totals_on_nct_id ON ctgov.reported_event_totals USING btree (nct_id);


--
-- Name: index_reported_events_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_reported_events_on_nct_id ON ctgov.reported_events USING btree (nct_id);


--
-- Name: index_responsible_parties_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_responsible_parties_on_nct_id ON ctgov.responsible_parties USING btree (nct_id);


--
-- Name: index_result_agreements_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_result_agreements_on_nct_id ON ctgov.result_agreements USING btree (nct_id);


--
-- Name: index_result_contacts_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_result_contacts_on_nct_id ON ctgov.result_contacts USING btree (nct_id);


--
-- Name: index_result_groups_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_result_groups_on_nct_id ON ctgov.result_groups USING btree (nct_id);


--
-- Name: index_search_results_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_search_results_on_nct_id ON ctgov.search_results USING btree (nct_id);


--
-- Name: index_sponsors_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sponsors_on_nct_id ON ctgov.sponsors USING btree (nct_id);


--
-- Name: index_studies_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_studies_on_nct_id ON ctgov.studies USING btree (nct_id);


--
-- Name: index_study_references_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_study_references_on_nct_id ON ctgov.study_references USING btree (nct_id);


--
-- Name: intervention_other_names_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX intervention_other_names_nct_idx ON ctgov.intervention_other_names USING btree (nct_id);


--
-- Name: interventions_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX interventions_nct_idx ON ctgov.interventions USING btree (nct_id);


--
-- Name: ipd_information_types_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX ipd_information_types_nct_idx ON ctgov.ipd_information_types USING btree (nct_id);


--
-- Name: keywords_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX keywords_nct_idx ON ctgov.keywords USING btree (nct_id);


--
-- Name: links_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX links_nct_idx ON ctgov.links USING btree (nct_id);


--
-- Name: milestones_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX milestones_nct_idx ON ctgov.milestones USING btree (nct_id);


--
-- Name: outcome_analyses_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX outcome_analyses_nct_idx ON ctgov.outcome_analyses USING btree (nct_id);


--
-- Name: outcome_analysis_groups_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX outcome_analysis_groups_nct_idx ON ctgov.outcome_analysis_groups USING btree (nct_id);


--
-- Name: outcome_counts_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX outcome_counts_nct_idx ON ctgov.outcome_counts USING btree (nct_id);


--
-- Name: outcome_measurements_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX outcome_measurements_nct_idx ON ctgov.outcome_measurements USING btree (nct_id);


--
-- Name: outcomes_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX outcomes_nct_idx ON ctgov.outcomes USING btree (nct_id);


--
-- Name: overall_officials_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX overall_officials_nct_idx ON ctgov.overall_officials USING btree (nct_id);


--
-- Name: participant_flows_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX participant_flows_nct_idx ON ctgov.participant_flows USING btree (nct_id);


--
-- Name: pending_results_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX pending_results_nct_idx ON ctgov.pending_results USING btree (nct_id);


--
-- Name: provided_documents_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX provided_documents_nct_idx ON ctgov.provided_documents USING btree (nct_id);


--
-- Name: reported_event_totals_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX reported_event_totals_nct_idx ON ctgov.reported_event_totals USING btree (nct_id);


--
-- Name: reported_events_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX reported_events_nct_idx ON ctgov.reported_events USING btree (nct_id);


--
-- Name: responsible_parties_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX responsible_parties_nct_idx ON ctgov.responsible_parties USING btree (nct_id);


--
-- Name: result_agreements_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX result_agreements_nct_idx ON ctgov.result_agreements USING btree (nct_id);


--
-- Name: result_contacts_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX result_contacts_nct_idx ON ctgov.result_contacts USING btree (nct_id);


--
-- Name: result_groups_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX result_groups_nct_idx ON ctgov.result_groups USING btree (nct_id);


--
-- Name: sponsors_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX sponsors_nct_idx ON ctgov.sponsors USING btree (nct_id);


--
-- Name: studies_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX studies_nct_idx ON ctgov.studies USING btree (nct_id);


--
-- Name: study_references_nct_idx; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX study_references_nct_idx ON ctgov.study_references USING btree (nct_id);


--
-- Name: index_lookup.authors_on_downcase_name; Type: INDEX; Schema: lookup; Owner: -
--

CREATE INDEX "index_lookup.authors_on_downcase_name" ON lookup.authors USING btree (downcase_name);


--
-- Name: index_lookup.authors_on_name; Type: INDEX; Schema: lookup; Owner: -
--

CREATE INDEX "index_lookup.authors_on_name" ON lookup.authors USING btree (name);


--
-- Name: index_lookup.authors_on_qcode; Type: INDEX; Schema: lookup; Owner: -
--

CREATE INDEX "index_lookup.authors_on_qcode" ON lookup.authors USING btree (qcode);


--
-- Name: index_pubmed.author_affiliations_on_pubmed.author_id; Type: INDEX; Schema: pubmed; Owner: -
--

CREATE INDEX "index_pubmed.author_affiliations_on_pubmed.author_id" ON pubmed.author_affiliations USING btree ("pubmed.author_id");


--
-- Name: index_pubmed.authors_on_pubmed.publication_id; Type: INDEX; Schema: pubmed; Owner: -
--

CREATE INDEX "index_pubmed.authors_on_pubmed.publication_id" ON pubmed.authors USING btree ("pubmed.publication_id");


--
-- Name: baseline_counts baseline_counts_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_counts
    ADD CONSTRAINT baseline_counts_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- Name: baseline_measurements baseline_measurements_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_measurements
    ADD CONSTRAINT baseline_measurements_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- Name: design_group_interventions design_group_interventions_design_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_group_interventions
    ADD CONSTRAINT design_group_interventions_design_group_id_fkey FOREIGN KEY (design_group_id) REFERENCES ctgov.design_groups(id);


--
-- Name: design_group_interventions design_group_interventions_intervention_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_group_interventions
    ADD CONSTRAINT design_group_interventions_intervention_id_fkey FOREIGN KEY (intervention_id) REFERENCES ctgov.interventions(id);


--
-- Name: drop_withdrawals drop_withdrawals_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.drop_withdrawals
    ADD CONSTRAINT drop_withdrawals_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- Name: facility_contacts facility_contacts_facility_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_contacts
    ADD CONSTRAINT facility_contacts_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES ctgov.facilities(id);


--
-- Name: facility_investigators facility_investigators_facility_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_investigators
    ADD CONSTRAINT facility_investigators_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES ctgov.facilities(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES ctgov.active_storage_blobs(id);


--
-- Name: intervention_other_names intervention_other_names_intervention_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.intervention_other_names
    ADD CONSTRAINT intervention_other_names_intervention_id_fkey FOREIGN KEY (intervention_id) REFERENCES ctgov.interventions(id);


--
-- Name: milestones milestones_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.milestones
    ADD CONSTRAINT milestones_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- Name: outcome_analyses outcome_analyses_outcome_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analyses
    ADD CONSTRAINT outcome_analyses_outcome_id_fkey FOREIGN KEY (outcome_id) REFERENCES ctgov.outcomes(id);


--
-- Name: outcome_analysis_groups outcome_analysis_groups_outcome_analysis_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analysis_groups
    ADD CONSTRAINT outcome_analysis_groups_outcome_analysis_id_fkey FOREIGN KEY (outcome_analysis_id) REFERENCES ctgov.outcome_analyses(id);


--
-- Name: outcome_analysis_groups outcome_analysis_groups_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analysis_groups
    ADD CONSTRAINT outcome_analysis_groups_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- Name: outcome_counts outcome_counts_outcome_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_counts
    ADD CONSTRAINT outcome_counts_outcome_id_fkey FOREIGN KEY (outcome_id) REFERENCES ctgov.outcomes(id);


--
-- Name: outcome_counts outcome_counts_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_counts
    ADD CONSTRAINT outcome_counts_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- Name: outcome_measurements outcome_measurements_outcome_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_measurements
    ADD CONSTRAINT outcome_measurements_outcome_id_fkey FOREIGN KEY (outcome_id) REFERENCES ctgov.outcomes(id);


--
-- Name: outcome_measurements outcome_measurements_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_measurements
    ADD CONSTRAINT outcome_measurements_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- Name: reported_events reported_events_result_group_id_fkey; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_events
    ADD CONSTRAINT reported_events_result_group_id_fkey FOREIGN KEY (result_group_id) REFERENCES ctgov.result_groups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20181201000144'),
('20181214000144'),
('20190514000142'),
('20190516000142'),
('20190527000442'),
('20190527800143'),
('20190528800143'),
('20190529800143'),
('20190601000144');


