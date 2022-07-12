/* Drop Tables */

DROP TABLE IF EXISTS processes.Action CASCADE;
DROP TABLE IF EXISTS processes.Action_in_parallel_activity CASCADE;
DROP TABLE IF EXISTS processes.Administrator CASCADE;
DROP TABLE IF EXISTS processes.Decision CASCADE;
DROP TABLE IF EXISTS processes.Decision_table CASCADE;
DROP TABLE IF EXISTS processes.Decision_table_entry CASCADE;
DROP TABLE IF EXISTS processes.Parallel_activity CASCADE;
DROP TABLE IF EXISTS processes.Process CASCADE;
DROP TABLE IF EXISTS processes.Process_link CASCADE;
DROP TABLE IF EXISTS processes.Process_status_type CASCADE;
DROP TABLE IF EXISTS processes.Process_usage CASCADE;
DROP TABLE IF EXISTS processes.Step CASCADE;
DROP TABLE IF EXISTS processes.Step_click CASCADE;
DROP TABLE IF EXISTS processes.Step_link CASCADE;
DROP TABLE IF EXISTS processes.Option CASCADE;

/* Create Domains */

CREATE DOMAIN processes.d_time AS
    timestamp NOT NULL DEFAULT LOCALTIMESTAMP(0) CONSTRAINT CHK_d_time_from_2020_to_2200 CHECK (VALUE >= '2020-01-01' AND VALUE < '2201-01-01');

CREATE DOMAIN processes.d_url AS varchar(2000) NOT NULL CONSTRAINT CHK_d_url_valid CHECK (VALUE ~* '^http[s]{0,1}://.*[.].*');


/* Create Tables */

CREATE TABLE processes.Administrator
(
    administrator_id serial       NOT NULL,
    email            varchar(254) NOT NULL,
    password         varchar(60)  NOT NULL,
    given_name       varchar(800) NULL,
    surname          varchar(800) NULL,
    is_active        boolean      NOT NULL DEFAULT TRUE,
    reg_time         processes.d_time,
    CONSTRAINT PK_Administrator PRIMARY KEY (administrator_id),
    CONSTRAINT CHK_Administrator_must_have_a_name CHECK (given_name IS NOT NULL OR surname IS NOT NULL),
    CONSTRAINT CHK_Administrator_password_not_only_whitespace CHECK (password !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Administrator_given_name_not_only_whitespace CHECK (given_name !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Administrator_surname_not_only_whitespace CHECK (surname !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Administrator_e_mail_at_least_one_at CHECK (email LIKE '%@%')
) WITH (FILLFACTOR = 90);
CREATE UNIQUE INDEX IX_Administrator_email_unique ON processes.Administrator (lower(email));

CREATE TABLE processes.Process_status_type
(
    process_status_type_code smallint    NOT NULL,
    name                     varchar(50) NOT NULL,
    CONSTRAINT PK_Process_status_type PRIMARY KEY (process_status_type_code),
    CONSTRAINT AK_Process_status_type_name UNIQUE (name),
    CONSTRAINT CHK_Process_status_type_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$')
);

CREATE TABLE processes.Process
(
    process_id               serial       NOT NULL,
    name                     varchar(250) NOT NULL,
    description              text         NOT NULL,
    owner_id                 integer      NOT NULL,
    first_step_id            integer      NULL,
    reg_time                 processes.d_time,
    process_status_type_code smallint     NOT NULL DEFAULT 1,
    password                 varchar(60)  NULL,
    CONSTRAINT PK_Process PRIMARY KEY (process_id),
    CONSTRAINT AK_Process_first_step_id UNIQUE (first_step_id),
    CONSTRAINT CHK_Process_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Process_description_not_only_whitespace CHECK (description !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Process_password_not_only_whitespace CHECK (password !~ '^[[:space:]]*$'),
    CONSTRAINT FK_Process_Process_status_type FOREIGN KEY (process_status_type_code) REFERENCES processes.Process_status_type (process_status_type_code) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Process_Administrator FOREIGN KEY (owner_id) REFERENCES processes.Administrator (administrator_id) ON DELETE NO ACTION ON UPDATE NO ACTION
) WITH (FILLFACTOR = 90);
CREATE INDEX IX_Process_owner ON processes.Process (owner_id ASC);
CREATE INDEX IX_Process_process_status_type_code ON processes.Process (process_status_type_code ASC);

CREATE TABLE processes.Step
(
    step_id      serial  NOT NULL,
    process_id   integer NOT NULL,
    reg_time     processes.d_time,
    description  text    NOT NULL,
    next_step_id integer NULL,
    CONSTRAINT PK_Step PRIMARY KEY (step_id),
    CONSTRAINT CHK_Step_description_not_only_whitespace CHECK (description !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Step_next_step_not_itself CHECK (next_step_id <> step_id),
    CONSTRAINT FK_Step_Step FOREIGN KEY (next_step_id) REFERENCES processes.Step (step_id) ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT FK_Step_Process FOREIGN KEY (process_id) REFERENCES processes.Process (process_id) ON DELETE NO ACTION ON UPDATE NO ACTION
) WITH (FILLFACTOR = 90);
CREATE INDEX IX_Step_Process ON processes.Step (process_id ASC);
CREATE INDEX IX_Step_next_step ON processes.Step (next_step_id ASC);

/* Add First_step FK to Process */
ALTER TABLE processes.Process
    ADD CONSTRAINT FK_Process_Step_first_step FOREIGN KEY (first_step_id) REFERENCES processes.Step (step_id) ON DELETE SET NULL ON UPDATE NO ACTION;

CREATE TABLE processes.Action
(
    action_id integer NOT NULL,
    CONSTRAINT PK_Action PRIMARY KEY (action_id),
    CONSTRAINT FK_Action_Step FOREIGN KEY (action_id) REFERENCES processes.Step (step_id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE processes.Parallel_activity
(
    parallel_activity_id integer NOT NULL,
    CONSTRAINT PK_Parallel_activity PRIMARY KEY (parallel_activity_id),
    CONSTRAINT FK_Parallel_activity_Step FOREIGN KEY (parallel_activity_id) REFERENCES processes.Step (step_id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE processes.Action_in_parallel_activity
(
    action_id            integer NOT NULL,
    parallel_activity_id integer NOT NULL,
    reg_time             processes.d_time,
    CONSTRAINT PK_Action_in_parallel_activity PRIMARY KEY (action_id),
    CONSTRAINT FK_Action_in_parallel_activity_Parallel_activity FOREIGN KEY (parallel_activity_id) REFERENCES processes.Parallel_activity (parallel_activity_id) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_Action_in_parallel_activity_Action FOREIGN KEY (action_id) REFERENCES processes.Action (action_id) ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE INDEX IX_Action_in_parallel_activity_Parallel_activity ON processes.Action_in_parallel_activity (parallel_activity_id ASC);

CREATE TABLE processes.Decision
(
    decision_id integer NOT NULL,
    CONSTRAINT PK_Decision PRIMARY KEY (decision_id),
    CONSTRAINT FK_Decision_Step FOREIGN KEY (decision_id) REFERENCES processes.Step (step_id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE processes.Option
(
    option_id    serial         NOT NULL,
    decision_id  integer        NOT NULL,
    next_step_id integer        NULL,
    weight       decimal(10, 3) NULL,
    reg_time     processes.d_time,
    guard        text           NOT NULL,
    CONSTRAINT PK_Option PRIMARY KEY (option_id),
    CONSTRAINT CHK_Option_guard_not_only_whitespace CHECK (guard !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Option_next_step_not_its_parent CHECK (next_step_id <> decision_id),
    CONSTRAINT CHK_Option_guard_max_length CHECK (char_length(guard) <= 1000),
    CONSTRAINT AK_Option_decision_guard UNIQUE (decision_id, guard),
    CONSTRAINT FK_Option_Decision FOREIGN KEY (decision_id) REFERENCES processes.Decision (decision_id) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_Option_Step FOREIGN KEY (next_step_id) REFERENCES processes.Step (step_id) ON DELETE SET NULL ON UPDATE NO ACTION
) WITH (FILLFACTOR = 90);
CREATE INDEX IX_Option_next_step ON processes.Option (next_step_id ASC);

CREATE TABLE processes.Process_link
(
    process_link_id serial        NOT NULL,
    process_id      integer       NOT NULL,
    url             processes.d_url,
    name            varchar(1000) NULL,
    priority_nr     smallint      NOT NULL,
    reg_time        processes.d_time,
    CONSTRAINT PK_Process_link PRIMARY KEY (process_link_id),
    CONSTRAINT AK_Process_link_priority UNIQUE (process_id, priority_nr),
    CONSTRAINT AK_Process_link_url UNIQUE (url, process_id),
    CONSTRAINT FK_Process_link_Process FOREIGN KEY (process_id) REFERENCES processes.Process (process_id) ON DELETE CASCADE ON UPDATE NO ACTION
) WITH (FILLFACTOR = 90);

CREATE TABLE processes.Step_link
(
    step_link_id serial        NOT NULL,
    step_id      integer       NOT NULL,
    url          processes.d_url,
    name         varchar(1000) NULL,
    priority_nr  smallint      NOT NULL,
    reg_time     processes.d_time,
    CONSTRAINT PK_Step_link PRIMARY KEY (step_link_id),
    CONSTRAINT AK_Step_link_priority UNIQUE (step_id, priority_nr),
    CONSTRAINT AK_Step_link_url UNIQUE (url, step_id),
    CONSTRAINT FK_Step_link_Step FOREIGN KEY (step_id) REFERENCES processes.Step (step_id) ON DELETE CASCADE ON UPDATE NO ACTION
) WITH (FILLFACTOR = 90);

CREATE TABLE processes.Decision_table
(
    decision_table_id serial       NOT NULL,
    action_id         integer      NOT NULL,
    name              varchar(500) NOT NULL,
    is_active         boolean      NOT NULL DEFAULT TRUE,
    reg_time          processes.d_time,
    CONSTRAINT PK_Decision_table PRIMARY KEY (decision_table_id),
    CONSTRAINT CHK_Decision_table_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT FK_Decision_table_Action FOREIGN KEY (action_id) REFERENCES processes.Action (action_id) ON DELETE CASCADE ON UPDATE NO ACTION
) WITH (FILLFACTOR = 90);
CREATE INDEX IX_Decision_table_action_id ON processes.Decision_table (action_id ASC);

CREATE TABLE processes.Decision_table_entry
(
    decision_table_entry_id serial   NOT NULL,
    decision_table_id       integer  NOT NULL,
    condition               text     NOT NULL,
    action                  text     NOT NULL,
    seq_nr                  smallint NOT NULL,
    reg_time                processes.d_time,
    CONSTRAINT PK_Decision_table_entry PRIMARY KEY (decision_table_entry_id),
    CONSTRAINT AK_decision_table_entry_seq_nr UNIQUE (decision_table_id, seq_nr),
    CONSTRAINT AK_decision_table_entry_condition UNIQUE (condition, decision_table_id),
    CONSTRAINT CHK_Decision_table_entry_condition_not_only_whitespace CHECK (condition !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Decision_table_entry_action_not_only_whitespace CHECK (action !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Decision_table_entry_condition_max_length CHECK (char_length(condition) <= 1000),
    CONSTRAINT CHK_Decision_table_entry_action_max_length CHECK (char_length(action) <= 1000),
    CONSTRAINT FK_Decision_table_entry_Decision_table FOREIGN KEY (decision_table_id) REFERENCES processes.Decision_table (decision_table_id) ON DELETE CASCADE ON UPDATE NO ACTION
) WITH (FILLFACTOR = 90);

CREATE TABLE processes.Process_usage
(
    process_usage_id bigserial NOT NULL,
    process_id       integer   NOT NULL,
    CONSTRAINT PK_Process_usage PRIMARY KEY (process_usage_id),
    CONSTRAINT FK_Process_usage_Process FOREIGN KEY (process_id) REFERENCES processes.Process (process_id) ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE INDEX IX_Process_usage_process_id ON processes.Process_usage (process_id ASC);

CREATE TABLE processes.Step_click
(
    step_click_id    bigserial NOT NULL,
    process_usage_id bigint    NOT NULL,
    step_id          integer   NOT NULL,
    click_time       processes.d_time,
    CONSTRAINT PK_Step_click PRIMARY KEY (step_click_id),
    CONSTRAINT FK_Step_click_Step FOREIGN KEY (step_id) REFERENCES processes.Step (step_id) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_Step_click_Process_usage FOREIGN KEY (process_usage_id) REFERENCES processes.Process_usage (process_usage_id) ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE INDEX IX_Step_click_step_id ON processes.Step_click (step_id ASC);
CREATE INDEX IX_Step_click_process_usage_id ON processes.Step_click (process_usage_id ASC);
