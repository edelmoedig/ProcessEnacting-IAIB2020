CREATE OR REPLACE VIEW all_processes WITH (security_barrier) AS
SELECT Process.process_id,
       Process.name,
       Process.description,
       Process.password IS NOT NULL                                                     AS has_password,
       Process_status_type.name                                                         AS current_status,
       format('%1$s %2$s', trim(Administrator.given_name), trim(Administrator.surname)) AS owner,
       Process.reg_time
FROM Process_status_type
         INNER JOIN (Administrator INNER JOIN Process ON Administrator.administrator_id = Process.owner_id)
                    ON Process_status_type.process_status_type_code = Process.process_status_type_code;

COMMENT ON VIEW all_processes IS 'This view shows basic information about every existing process.';

CREATE OR REPLACE VIEW active_and_inactive_processes WITH (security_barrier) AS
SELECT Process.process_id,
       Process.name,
       Process.description,
       Process.password IS NOT NULL                                                     AS has_password,
       Process_status_type.name                                                         AS current_status,
       format('%1$s %2$s', trim(Administrator.given_name), trim(Administrator.surname)) AS owner,
       Process.reg_time
FROM Process_status_type
         INNER JOIN (Administrator INNER JOIN Process ON Administrator.administrator_id = Process.owner_id)
                    ON Process_status_type.process_status_type_code = Process.process_status_type_code
WHERE Process_status_type.process_status_type_code IN (2, 3);

COMMENT ON VIEW active_and_inactive_processes IS 'This view shows basic information about every active and inactive process.';
