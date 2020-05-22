CREATE OR REPLACE VIEW processes.all_processes WITH (security_barrier) AS
SELECT Process.process_id,
       Process.name                                                                               AS process_name,
       Process.description                                                                        AS process_description,
       Process.password IS NOT NULL                                                               AS has_password,
       Process_status_type.name                                                                   AS current_status,
       format('%1$s %2$s', trim(processes.Administrator.given_name), trim(processes.Administrator.surname)) AS owner,
       Process.first_step_id                                                                      AS first_step,
       Process.reg_time
FROM processes.Process_status_type
         INNER JOIN (processes.Administrator INNER JOIN processes.Process ON processes.Administrator.administrator_id = processes.Process.owner_id)
                    ON processes.Process_status_type.process_status_type_code =
                       processes.Process.process_status_type_code;

COMMENT ON VIEW processes.all_processes IS 'This view shows basic information about every existing process.';

CREATE OR REPLACE VIEW processes.active_inactive_on_hold_processes WITH (security_barrier) AS
SELECT Process.process_id,
       Process.name                 AS process_name,
       Process.description          AS process_description,
       Process.password IS NOT NULL AS has_password,
       Process_status_type.name     AS current_status,
       Process.owner_id             AS owner,
       Process.first_step_id        AS first_step,
       Process.reg_time
FROM processes.Process_status_type
         INNER JOIN processes.Process
                    ON processes.Process_status_type.process_status_type_code =
                       processes.Process.process_status_type_code
WHERE processes.Process_status_type.process_status_type_code IN (1, 2, 3);

COMMENT ON VIEW processes.active_inactive_on_hold_processes IS 'This view shows basic information about every active, inactive, and never activated (on hold) process.';

CREATE OR REPLACE VIEW processes.active_processes WITH (security_barrier) AS
SELECT Process.process_id,
       Process.name                                                                               AS process_name,
       Process.description                                                                        AS process_description,
       Process.password IS NOT NULL                                                               AS has_password,
       format('%1$s %2$s', trim(processes.Administrator.given_name), trim(processes.Administrator.surname)) AS owner,
       Process.first_step_id                                                                      AS first_step,
       Process.reg_time
FROM processes.Process_status_type
         INNER JOIN (processes.Administrator INNER JOIN processes.Process ON processes.Administrator.administrator_id = processes.Process.owner_id)
WHERE processes.Process_status_type.process_status_type_code = 2;

COMMENT ON VIEW processes.active_processes IS 'This view shows basic information about every active process.';

CREATE OR REPLACE VIEW processes.process_steps WITH (security_barrier) AS
SELECT step_id,
       CASE WHEN decision_id IS NULL THEN FALSE ELSE TRUE END          AS is_decision,
       CASE WHEN parallel_activity_id IS NULL THEN FALSE ELSE TRUE END AS is_parallel_activity,
       description,
       next_step_id
FROM processes.Step
         LEFT JOIN processes.Decision ON step_id = decision_id
         LEFT JOIN processes.Parallel_activity ON step_id = parallel_activity_id;

COMMENT ON VIEW processes.process_steps IS 'This view shows information about every step including whether the step is a decision step or a parallel activity.';

CREATE OR REPLACE VIEW processes.parallel_actions WITH (security_barrier) AS
    SELECT parallel_activity_id, action_id FROM processes.Action_in_parallel_activity;

COMMENT ON VIEW processes.process_steps IS 'This view shows information about every action step inside a parallel activity.';

CREATE OR REPLACE VIEW processes.decision_options WITH (security_barrier) AS
SELECT decision_id, next_step_id, guard, weight
FROM processes.Option;

COMMENT ON VIEW processes.process_steps IS 'This view shows information about every option.';

CREATE OR REPLACE VIEW processes.decision_tables WITH (security_barrier) AS
SELECT decision_table_id,
       action_id AS associated_step,
       name      AS decision_table_name,
       is_active
FROM processes.Decision_table;

COMMENT ON VIEW processes.decision_tables IS 'This view shows information about every decision table.';

CREATE OR REPLACE VIEW processes.decision_table_entries WITH (security_barrier) AS
SELECT decision_table_id,
       condition,
       action,
       seq_nr
FROM processes.Decision_table_entry;

COMMENT ON VIEW processes.decision_table_entries IS 'This view shows information about every decision table entry.';

CREATE OR REPLACE VIEW processes.process_links WITH (security_barrier) AS
SELECT process_link_id,
       process_id,
       url,
       name AS process_link_name,
       priority_nr
FROM processes.Process_link;

COMMENT ON VIEW processes.process_links IS 'This view shows information about every link connected to a process.';

CREATE OR REPLACE VIEW processes.step_links WITH (security_barrier) AS
SELECT step_link_id,
       step_id,
       url,
       name AS step_link_name,
       priority_nr
FROM processes.step_link;

COMMENT ON VIEW processes.step_links IS 'This view shows information about every link connected to a step.';
