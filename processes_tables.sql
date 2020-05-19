/* Drop Tables */

DROP TABLE IF EXISTS Action CASCADE;
DROP TABLE IF EXISTS Action_in_parallel_activity CASCADE;
DROP TABLE IF EXISTS Administrator CASCADE;
DROP TABLE IF EXISTS Decision CASCADE;
DROP TABLE IF EXISTS Decision_table CASCADE;
DROP TABLE IF EXISTS Decision_table_entry CASCADE;
DROP TABLE IF EXISTS Parallel_activity CASCADE;
DROP TABLE IF EXISTS Process CASCADE;
DROP TABLE IF EXISTS Process_link CASCADE;
DROP TABLE IF EXISTS Process_status_type CASCADE;
DROP TABLE IF EXISTS Process_usage CASCADE;
DROP TABLE IF EXISTS Step CASCADE;
DROP TABLE IF EXISTS Step_click CASCADE;
DROP TABLE IF EXISTS Step_link CASCADE;
DROP TABLE IF EXISTS Option CASCADE;

/* Create Tables */

CREATE TABLE Administrator
(
    administrator_id serial       NOT NULL,
    email            varchar(254) NOT NULL,
    password         varchar(60)  NOT NULL,
    given_name       varchar(800) NULL,
    surname          varchar(800) NULL,
    is_active        boolean      NOT NULL DEFAULT TRUE,
    reg_time         timestamp    NOT NULL DEFAULT LOCALTIMESTAMP(0),
    CONSTRAINT PK_Administrator PRIMARY KEY (administrator_id),
    CONSTRAINT CHK_Administrator_must_have_a_name CHECK (given_name IS NOT NULL OR surname IS NOT NULL),
    CONSTRAINT CHK_Administrator_password_not_only_whitespace CHECK (password !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Administrator_given_name_not_only_whitespace CHECK (given_name !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Administrator_surname_not_only_whitespace CHECK (surname !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Administrator_e_mail_at_least_one_at CHECK (email LIKE '%@%')
);
CREATE UNIQUE INDEX IX_Administrator_email_unique ON Administrator (lower(email));

CREATE TABLE Process_status_type
(
    process_status_type_code smallint    NOT NULL,
    name                     varchar(50) NOT NULL,
    CONSTRAINT PK_Process_status_type PRIMARY KEY (process_status_type_code),
    CONSTRAINT AK_Process_status_type_name UNIQUE (name),
    CONSTRAINT CHK_Process_status_type_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$')
);

CREATE TABLE Process
(
    process_id               serial       NOT NULL,
    name                     varchar(250) NOT NULL,
    description              text         NOT NULL,
    owner_id                 integer      NOT NULL,
    first_step_id            integer      NULL,
    reg_time                 timestamp    NOT NULL DEFAULT LOCALTIMESTAMP(0),
    process_status_type_code smallint     NOT NULL DEFAULT 1,
    password                 varchar(60)  NULL,
    CONSTRAINT PK_Process PRIMARY KEY (process_id),
    CONSTRAINT AK_Process_first_step_id UNIQUE (first_step_id),
    CONSTRAINT CHK_Process_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Process_description_not_only_whitespace CHECK (description !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Process_password_not_only_whitespace CHECK (password !~ '^[[:space:]]*$'),
    CONSTRAINT FK_Process_Process_status_type FOREIGN KEY (process_status_type_code) REFERENCES Process_status_type (process_status_type_code) ON DELETE No Action ON UPDATE Cascade,
    CONSTRAINT FK_Process_Administrator FOREIGN KEY (owner_id) REFERENCES Administrator (administrator_id) ON DELETE No Action ON UPDATE No Action
) WITH (fillfactor = 90);
CREATE INDEX IX_Process_owner ON Process (owner_id ASC);
CREATE INDEX IX_Process_process_status_type_code ON Process (process_status_type_code ASC);

CREATE TABLE Step
(
    step_id      serial    NOT NULL,
    process_id   integer   NOT NULL,
    reg_time     timestamp NOT NULL DEFAULT LOCALTIMESTAMP(0),
    description  text      NOT NULL,
    next_step_id integer   NULL,
    CONSTRAINT PK_Step PRIMARY KEY (step_id),
    CONSTRAINT CHK_Step_description_not_only_whitespace CHECK (description !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Step_next_step_not_itself CHECK (next_step_id <> step_id),
    CONSTRAINT FK_Step_Step FOREIGN KEY (next_step_id) REFERENCES Step (step_id) ON DELETE Set Null ON UPDATE No Action,
    CONSTRAINT FK_Step_Process FOREIGN KEY (process_id) REFERENCES Process (process_id) ON DELETE No Action ON UPDATE No Action
) WITH (fillfactor = 90);
CREATE INDEX IX_Step_Process ON Step (step_id ASC);
CREATE INDEX IX_Step_next_step ON Step (next_step_id ASC);

/* Add First_step FK to Process */
ALTER TABLE Process
    ADD CONSTRAINT FK_Process_Step_first_step FOREIGN KEY (first_step_id) REFERENCES Step (step_id) ON DELETE Set Null ON UPDATE No Action;

CREATE TABLE Action
(
    action_id integer NOT NULL,
    CONSTRAINT PK_Action PRIMARY KEY (action_id),
    CONSTRAINT FK_Action_Step FOREIGN KEY (action_id) REFERENCES Step (step_id) ON DELETE Cascade ON UPDATE No Action
);

CREATE TABLE Parallel_activity
(
    parallel_activity_id integer NOT NULL,
    CONSTRAINT PK_Parallel_activity PRIMARY KEY (parallel_activity_id),
    CONSTRAINT FK_Parallel_activity_Step FOREIGN KEY (parallel_activity_id) REFERENCES Step (step_id) ON DELETE Cascade ON UPDATE No Action
);

CREATE TABLE Action_in_parallel_activity
(
    action_id            integer   NOT NULL,
    parallel_activity_id integer   NOT NULL,
    reg_time             timestamp NOT NULL DEFAULT LOCALTIMESTAMP(0),
    CONSTRAINT PK_Action_in_parallel_activity PRIMARY KEY (action_id),
    CONSTRAINT FK_Action_in_parallel_activity_Parallel_activity FOREIGN KEY (parallel_activity_id) REFERENCES Parallel_activity (parallel_activity_id) ON DELETE Cascade ON UPDATE No Action,
    CONSTRAINT FK_Action_in_parallel_activity_Action FOREIGN KEY (action_id) REFERENCES Action (action_id) ON DELETE Cascade ON UPDATE No Action
);
CREATE INDEX IX_Action_in_parallel_activity_Parallel_activity ON Action_in_parallel_activity (parallel_activity_id ASC);

CREATE TABLE Decision
(
    decision_id integer NOT NULL,
    CONSTRAINT PK_Decision PRIMARY KEY (decision_id),
    CONSTRAINT FK_Decision_Step FOREIGN KEY (decision_id) REFERENCES Step (step_id) ON DELETE Cascade ON UPDATE No Action
);

CREATE TABLE Option
(
    option_id   serial         NOT NULL,
    decision_id  integer        NOT NULL,
    next_step_id integer        NULL,
    weight       decimal(10, 3) NULL,
    reg_time     timestamp      NOT NULL DEFAULT LOCALTIMESTAMP(0),
    guard        text           NOT NULL,
    CONSTRAINT PK_Option PRIMARY KEY (option_id),
    CONSTRAINT CHK_Option_guard_not_only_whitespace CHECK (guard !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Option_next_step_not_its_parent CHECK (next_step_id <> decision_id),
    CONSTRAINT AK_Option_decision_guard UNIQUE (decision_id, guard),
    CONSTRAINT FK_Option_Decision FOREIGN KEY (decision_id) REFERENCES Decision (decision_id) ON DELETE Cascade ON UPDATE No Action,
    CONSTRAINT FK_Option_Step FOREIGN KEY (next_step_id) REFERENCES Step (step_id) ON DELETE Cascade ON UPDATE No Action
);
CREATE INDEX IX_Option_next_step ON Option (next_step_id ASC);

CREATE TABLE Process_link
(
    process_link_id serial        NOT NULL,
    process_id      integer       NOT NULL,
    url             varchar(2000) NOT NULL,
    name            varchar(1000) NULL,
    priority_nr     smallint      NOT NULL,
    reg_time        timestamp     NOT NULL DEFAULT LOCALTIMESTAMP(0),
    CONSTRAINT PK_Process_link PRIMARY KEY (process_link_id),
    CONSTRAINT AK_Process_link_priority UNIQUE (process_id, priority_nr),
    CONSTRAINT AK_Process_link_url UNIQUE (url, process_id),
    CONSTRAINT CHK_Process_link_url_not_only_whitespace CHECK (url !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Process_link_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT FK_Process_link_Process FOREIGN KEY (process_id) REFERENCES Process (process_id) ON DELETE Cascade ON UPDATE No Action
);

CREATE TABLE Step_link
(
    step_link_id serial        NOT NULL,
    step_id      integer       NOT NULL,
    url          varchar(2000) NOT NULL,
    name         varchar(1000) NULL,
    priority_nr  smallint      NOT NULL,
    reg_time     timestamp     NOT NULL DEFAULT LOCALTIMESTAMP(0),
    CONSTRAINT PK_Step_link PRIMARY KEY (step_link_id),
    CONSTRAINT AK_Step_link_priority UNIQUE (step_id, priority_nr),
    CONSTRAINT AK_Step_link_url UNIQUE (url, step_id),
    CONSTRAINT CHK_Step_link_url_not_only_whitespace CHECK (url !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Step_link_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT FK_Step_link_Step FOREIGN KEY (step_id) REFERENCES Step (step_id) ON DELETE Cascade ON UPDATE No Action
);

CREATE TABLE Decision_table
(
    decision_table_id serial       NOT NULL,
    action_id         integer      NOT NULL,
    name              varchar(500) NOT NULL,
    is_active         boolean      NOT NULL DEFAULT TRUE,
    reg_time          timestamp    NOT NULL DEFAULT LOCALTIMESTAMP(0),
    CONSTRAINT PK_Decision_table PRIMARY KEY (decision_table_id),
    CONSTRAINT CHK_Decision_table_name_not_only_whitespace CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT FK_Decision_table_Action FOREIGN KEY (action_id) REFERENCES Action (action_id) ON DELETE Cascade ON UPDATE No Action
);
CREATE INDEX IX_Decision_table_action_id ON Decision_table (action_id ASC);

CREATE TABLE Decision_table_entry
(
    decision_table_entry_id serial    NOT NULL,
    decision_table_id       integer   NOT NULL,
    condition               text      NOT NULL,
    action                  text      NOT NULL,
    seq_nr                  smallint  NOT NULL,
    reg_time                timestamp NOT NULL DEFAULT LOCALTIMESTAMP(0),
    CONSTRAINT PK_Decision_table_entry PRIMARY KEY (decision_table_entry_id),
    CONSTRAINT AK_decision_table_entry_seq_nr UNIQUE (decision_table_id, seq_nr),
    CONSTRAINT AK_decision_table_entry_condition UNIQUE (condition, decision_table_id),
    CONSTRAINT CHK_Decision_table_entry_condition_not_only_whitespace CHECK (condition !~ '^[[:space:]]*$'),
    CONSTRAINT CHK_Decision_table_entry_action_not_only_whitespace CHECK (action !~ '^[[:space:]]*$'),
    CONSTRAINT FK_Decision_table_entry_Decision_table FOREIGN KEY (decision_table_id) REFERENCES Decision_table (decision_table_id) ON DELETE Cascade ON UPDATE No Action
);

CREATE TABLE Process_usage
(
    process_usage_id bigserial NOT NULL,
    process_id       integer   NOT NULL,
    CONSTRAINT PK_Process_usage PRIMARY KEY (process_usage_id),
    CONSTRAINT FK_Process_usage_Process FOREIGN KEY (process_id) REFERENCES Process (process_id) ON DELETE Cascade ON UPDATE No Action
);
CREATE INDEX IX_Process_usage_process_id ON Process_usage (process_id ASC);

CREATE TABLE Step_click
(
    step_click_id    bigserial NOT NULL,
    process_usage_id bigint    NOT NULL,
    step_id          integer   NOT NULL,
    click_time       timestamp NOT NULL DEFAULT LOCALTIMESTAMP(0),
    CONSTRAINT PK_Step_click PRIMARY KEY (step_click_id),
    CONSTRAINT FK_Step_click_Step FOREIGN KEY (step_id) REFERENCES Step (step_id) ON DELETE Cascade ON UPDATE No Action,
    CONSTRAINT FK_Step_click_Process_usage FOREIGN KEY (process_usage_id) REFERENCES Process_usage (process_usage_id) ON DELETE Cascade ON UPDATE No Action
);
CREATE INDEX IX_Step_click_step_id ON Step_click (step_id ASC);
CREATE INDEX IX_Step_click_process_usage_id ON Step_click (process_usage_id ASC);
