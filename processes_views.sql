CREATE OR REPLACE VIEW all_processes WITH (security_barrier) AS
SELECT processes.Process.process_id,
       processes.Process.name                                                                                 AS process_name,
       processes.Process.description                                                                          AS process_description,
       processes.Process.password IS NOT NULL                                                                 AS has_password,
       processes.Process_status_type.name                                                                                 AS current_status,
       format('%1$s %2$s', trim(processes.Administrator.given_name), trim(processes.Administrator.surname)) AS owner,
       processes.Process.reg_time
FROM processes.Process_status_type
         INNER JOIN (processes.Administrator INNER JOIN processes.Process ON processes.Administrator.administrator_id = processes.Process.owner_id)
                    ON processes.Process_status_type.process_status_type_code = processes.Process.process_status_type_code;

COMMENT ON VIEW all_processes IS 'This view shows basic information about every existing process.';

CREATE OR REPLACE VIEW active_and_inactive_processes WITH (security_barrier) AS
SELECT processes.Process.process_id,
       processes.Process.name                                                                                 AS process_name,
       processes.Process.description                                                                          AS process_description,
       processes.Process.password IS NOT NULL                                                                 AS has_password,
       processes.Process_status_type.name                                                                                 AS current_status,
       format('%1$s %2$s', trim(processes.Administrator.given_name), trim(processes.Administrator.surname)) AS owner,
       processes.Process.reg_time
FROM processes.Process_status_type
         INNER JOIN (processes.Administrator INNER JOIN processes.Process ON processes.Administrator.administrator_id = processes.Process.owner_id)
                    ON processes.Process_status_type.process_status_type_code = processes.Process.process_status_type_code
WHERE processes.Process_status_type.process_status_type_code IN (2, 3);

COMMENT ON VIEW active_and_inactive_processes IS 'This view shows basic information about every active and inactive process.';
