-- Administrators

CREATE OR REPLACE FUNCTION processes.f_register_administrator(p_email processes.Administrator.email%TYPE,
                                                              p_password processes.Administrator.password%TYPE,
                                                              p_given_name processes.Administrator.given_name%TYPE,
                                                              p_surname processes.Administrator.surname%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Administrator(email, password, given_name, surname)
SELECT p_email, p_password, p_given_name, p_surname FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_register_administrator(p_email processes.Administrator.email%TYPE,
    p_password processes.Administrator.password%TYPE,
    p_given_name processes.Administrator.given_name%TYPE,
    p_surname processes.Administrator.surname%TYPE)
    IS 'This function is used to register a new process administrator.';


-- Processes

CREATE OR REPLACE FUNCTION processes.f_register_process(p_name processes.Process.name%TYPE,
                                                        p_description processes.Process.description%TYPE,
                                                        p_owner processes.Process.owner_id%TYPE,
                                                        p_password processes.Process.password%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Process(name, description, owner_id, password)
SELECT p_name, p_description, p_owner, p_password FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_register_process(p_name processes.Process.name%TYPE,
    p_description processes.Process.description%TYPE,
    p_owner processes.Process.owner_id%TYPE,
    p_password processes.Process.password%TYPE)
    IS 'This function is used to register a new process.';



CREATE OR REPLACE FUNCTION processes.f_change_process_password(p_process_id processes.Process.process_id%TYPE,
                                                               p_password processes.Process.password%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Process
SET password = NULLIF(p_password, '')
WHERE process_id = p_process_id
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_process_password(p_process_id processes.Process.process_id%TYPE, p_password processes.Process.password%TYPE)
    IS 'This function is used to change a process''s password. If the provided password is empty, the process'' password is set to NULL instead.';



CREATE OR REPLACE FUNCTION processes.f_change_password_name_and_description(p_process_id processes.Process.process_id%TYPE,
                                                                            p_name processes.Process.name%TYPE,
                                                                            p_description processes.Process.description%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Process
SET name        = p_name,
    description = p_description
WHERE process_id = p_process_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_password_name_and_description(p_process_id processes.Process.process_id%TYPE,
    p_name processes.Process.name%TYPE,
    p_description processes.Process.description%TYPE)
    IS 'This function is used to change an existing process''s name and description.';



CREATE OR REPLACE FUNCTION processes.f_activate_process(p_process_id processes.Process.process_id%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Process
SET process_status_type_code = 2
WHERE process_id = p_process_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_activate_process(p_process_id processes.Process.process_id%TYPE)
    IS 'This function is to activate a process. The process can only be activated if it''s current status is "On hold" or "Inactive", every step is designed correctly, and the process can successfully be completed.';



CREATE OR REPLACE FUNCTION processes.f_deactivate_process(p_process_id processes.Process.process_id%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Process
SET process_status_type_code = 3
WHERE process_id = p_process_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_deactivate_process(p_process_id processes.Process.process_id%TYPE) IS 'This function is to deactivate a process. The process can only be deactivated if it''s current status is "Active".';



CREATE OR REPLACE FUNCTION processes.f_end_process(p_process_id processes.Process.process_id%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Process
SET process_status_type_code = 4
WHERE process_id = p_process_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_end_process(p_process_id processes.Process.process_id%TYPE)
    IS 'This function is to end a process by making it permanently inaccessible to users but keeping it in the database. The process can only be ended if it''s current status is "Active" or "Inactive".';



CREATE OR REPLACE FUNCTION processes.f_forget_process(p_process_id processes.Process.process_id%TYPE)
    RETURNS BOOLEAN AS $$
WITH forget_process AS (DELETE FROM processes.Process WHERE process_id = p_process_id RETURNING process_id)
SELECT Count(*) > 0 AS result
FROM forget_process;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_end_process(p_process_id processes.Process.process_id%TYPE)
    IS 'This function is to forget a process by deleting in from the database. The process can only be ended if it''s current status is "On hold". This function returns TRUE if the deletion was successful.';


-- Steps

CREATE OR REPLACE FUNCTION processes.f_add_first_action(p_process_id processes.Step.process_id%TYPE,
                                                        p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, description)
    VALUES (p_process_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Action(action_id) VALUES (v_step_id);
    UPDATE processes.Process SET first_step_id = v_step_id WHERE process_id = p_process_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_first_action(p_process_id processes.Step.process_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add the first step (action in this case) to a newly-created process.';



CREATE OR REPLACE FUNCTION processes.f_add_action_to_step(p_process_id processes.Step.process_id%TYPE,
                                                          p_previous_step_id processes.Step.next_step_id%TYPE,
                                                          p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, description)
    VALUES (p_process_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Action(action_id) VALUES (v_step_id);
    UPDATE processes.Step SET next_step_id = v_step_id WHERE processes.Step.step_id = p_previous_step_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_action_to_step(p_process_id processes.Step.process_id%TYPE,
    p_previous_step_id processes.Step.next_step_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add an action step connected to an existing previous step that does not lead to an existing step.';



CREATE OR REPLACE FUNCTION processes.f_add_action_to_step_existing_next(p_process_id processes.Step.process_id%TYPE,
                                                                        p_previous_step_id processes.Step.next_step_id%TYPE,
                                                                        p_next_step_id processes.Step.next_step_id%TYPE,
                                                                        p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, next_step_id, description)
    VALUES (p_process_id, p_next_step_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Action(action_id) VALUES (v_step_id);
    UPDATE processes.Step SET next_step_id = v_step_id WHERE processes.Step.step_id = p_previous_step_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_action_to_step_existing_next(p_process_id processes.Step.process_id%TYPE,
    p_previous_step_id processes.Step.next_step_id%TYPE,
    p_next_step_id processes.Step.next_step_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add an action step connected to an existing previous step that leads to an existing step.';



CREATE OR REPLACE FUNCTION processes.f_add_first_parallel_activity(p_process_id processes.Step.process_id%TYPE,
                                                                   p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, description)
    VALUES (p_process_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Parallel_activity(parallel_activity_id) VALUES (v_step_id);
    UPDATE processes.Process SET first_step_id = v_step_id WHERE process_id = p_process_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_first_parallel_activity(p_process_id processes.Step.process_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add the first step (parallel activity in this case) to a newly-created process.';



CREATE OR REPLACE FUNCTION processes.f_add_parallel_activity_to_step(p_process_id processes.Step.process_id%TYPE,
                                                                     p_previous_step_id processes.Step.next_step_id%TYPE,
                                                                     p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, description)
    VALUES (p_process_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Parallel_activity(parallel_activity_id) VALUES (v_step_id);
    UPDATE processes.Step SET next_step_id = v_step_id WHERE processes.Step.step_id = p_previous_step_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_parallel_activity_to_step(p_process_id processes.Step.process_id%TYPE,
    p_previous_step_id processes.Step.next_step_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add a parallel activity connected to an existing previous step that does not lead to an existing step.';



CREATE OR REPLACE FUNCTION processes.f_add_parallel_activity_to_step_existing_next(p_process_id processes.Step.process_id%TYPE,
                                                                                   p_previous_step_id processes.Step.next_step_id%TYPE,
                                                                                   p_next_step_id processes.Step.next_step_id%TYPE,
                                                                                   p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, next_step_id, description)
    VALUES (p_process_id, p_next_step_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Parallel_activity(parallel_activity_id) VALUES (v_step_id);
    UPDATE processes.Step SET next_step_id = v_step_id WHERE processes.Step.step_id = p_previous_step_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_parallel_activity_to_step_existing_next(p_process_id processes.Step.process_id%TYPE,
    p_previous_step_id processes.Step.next_step_id%TYPE,
    p_next_step_id processes.Step.next_step_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add a parallel activity connected to an existing previous step that leads to an existing step.';



CREATE OR REPLACE FUNCTION processes.f_add_action_in_parallel_activity(p_process_id processes.Step.process_id%TYPE,
                                                                       p_parallel_activity_id processes.Parallel_activity.parallel_activity_id%TYPE,
                                                                       p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, description)
    VALUES (p_process_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Action(action_id) VALUES (v_step_id);
    INSERT INTO processes.Action_in_parallel_activity(parallel_activity_id, action_id)
    VALUES (p_parallel_activity_id, v_step_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_action_in_parallel_activity(p_process_id processes.Step.process_id%TYPE,
    p_parallel_activity_id processes.Parallel_activity.parallel_activity_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add a new action to an existing parallel activity in an existing process.';



CREATE OR REPLACE FUNCTION processes.f_add_first_decision(p_process_id processes.Step.process_id%TYPE,
                                                          p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, description)
    VALUES (p_process_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Decision(decision_id) VALUES (v_step_id);
    UPDATE processes.Process SET first_step_id = v_step_id WHERE process_id = p_process_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_first_decision(p_process_id processes.Step.process_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add the first step (decision in this case) to a newly-created process.';



CREATE OR REPLACE FUNCTION processes.f_add_decision_to_step(p_process_id processes.Step.process_id%TYPE,
                                                            p_previous_step_id processes.Step.next_step_id%TYPE,
                                                            p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, description)
    VALUES (p_process_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Decision(decision_id) VALUES (v_step_id);
    UPDATE processes.Step SET next_step_id = v_step_id WHERE processes.Step.step_id = p_previous_step_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_decision_to_step(p_process_id processes.Step.process_id%TYPE,
    p_previous_step_id processes.Step.next_step_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add a decision step connected to an existing previous step that does not lead to an existing step.';



CREATE OR REPLACE FUNCTION processes.f_add_decision_to_step_existing_next(p_process_id processes.Step.process_id%TYPE,
                                                                          p_previous_step_id processes.Step.next_step_id%TYPE,
                                                                          p_next_step_id processes.Step.next_step_id%TYPE,
                                                                          p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
DECLARE
    v_step_id processes.Step.next_step_id%TYPE;
BEGIN
    INSERT INTO processes.Step(process_id, next_step_id, description)
    VALUES (p_process_id, p_next_step_id, p_description)
    RETURNING step_id INTO v_step_id;
    INSERT INTO processes.Decision(decision_id) VALUES (v_step_id);
    UPDATE processes.Step SET next_step_id = v_step_id WHERE processes.Step.step_id = p_previous_step_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_decision_to_step(p_process_id processes.Step.process_id%TYPE,
    p_previous_step_id processes.Step.next_step_id%TYPE,
    p_description processes.Step.description%TYPE)
    IS 'This function is used to add a decision step connected to an existing previous step that leads to an existing step.';



CREATE OR REPLACE FUNCTION processes.f_add_option_to_decision(p_decision_id processes.Option.decision_id%TYPE,
                                                              p_weight processes.Option.weight%TYPE,
                                                              p_guard processes.Option.guard%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Option(decision_id, weight, guard)
SELECT p_decision_id, p_weight, p_guard FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_option_to_decision(p_decision_id processes.Option.decision_id%TYPE,
    p_weight processes.Option.weight%TYPE,
    p_guard processes.Option.guard%TYPE)
    IS 'This function is used to add an option to an existing decision step.';



CREATE OR REPLACE FUNCTION processes.f_remove_option_from_decision(p_option_id processes.Option.decision_id%TYPE)
    RETURNS VOID AS $$
DELETE
FROM processes.Option
WHERE option_id = p_option_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_option_from_decision(p_option_id processes.Option.decision_id%TYPE)
    IS 'This function is used to remove an option from an existing decision step.';



CREATE OR REPLACE FUNCTION processes.f_change_option_weight_and_guard(p_option_id processes.Option.decision_id%TYPE,
                                                                      p_guard processes.Option.guard%TYPE,
                                                                      p_weight processes.Option.weight%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Option
SET guard  = p_guard,
    weight = p_weight
WHERE option_id = p_option_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_option_weight_and_guard(p_option_id processes.Option.decision_id%TYPE,
    p_guard processes.Option.guard%TYPE,
    p_weight processes.Option.weight%TYPE)
    IS 'This function is used to change an existing option''s associated text or weight.';



CREATE OR REPLACE FUNCTION processes.f_remove_step(p_step_id processes.Step.step_id%TYPE)
    RETURNS VOID AS $$
DELETE
FROM processes.Step
WHERE step_id = p_step_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_step(p_step_id processes.Step.step_id%TYPE)
    IS 'This function is used to remove a step from an existing process.';



CREATE OR REPLACE FUNCTION processes.f_change_step_description(p_step_id processes.Step.step_id%TYPE,
                                                               p_description processes.Step.description%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Step
SET description = p_description
WHERE step_id = p_step_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;


COMMENT ON FUNCTION processes.f_change_step_description(p_step_id processes.Step.step_id%TYPE, p_description processes.Step.description%TYPE)
    IS 'This function is used to change a step''s description.';


-- Links

CREATE OR REPLACE FUNCTION processes.f_add_process_link(p_process_id processes.Process_link.process_id%TYPE,
                                                        p_url processes.Process_link.url%TYPE,
                                                        p_name processes.Process_link.name%TYPE,
                                                        p_priority_nr processes.Process_link.priority_nr%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Process_link(process_id, url, name, priority_nr)
SELECT p_process_id, p_url, p_name, p_priority_nr FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_process_link(p_process_id processes.Process_link.process_id%TYPE,
    p_url processes.Process_link.url%TYPE,
    p_name processes.Process_link.name%TYPE,
    p_priority_nr processes.Process_link.priority_nr%TYPE)
    IS 'This function is used to add a link to a process in general.';



CREATE OR REPLACE FUNCTION processes.f_remove_process_link(p_process_link_id processes.Process_link.process_link_id%TYPE)
    RETURNS VOID AS $$
DELETE
FROM processes.Process_link
WHERE process_link_id = p_process_link_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_process_link(p_process_link_id processes.Process_link.process_link_id%TYPE)
    IS 'This function is used to remove an associated link from an existing process.';



CREATE OR REPLACE FUNCTION processes.f_add_step_link(p_step_id processes.Step_link.step_id%TYPE,
                                                     p_url processes.Step_link.url%TYPE,
                                                     p_name processes.Step_link.name%TYPE,
                                                     p_priority_nr processes.Step_link.priority_nr%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Step_link(step_id, url, name, priority_nr)
SELECT p_step_id, p_url, p_name, p_priority_nr FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_step_link(p_step_id processes.Step_link.step_id%TYPE,
    p_url processes.Step_link.url%TYPE,
    p_name processes.Step_link.name%TYPE,
    p_priority_nr processes.Step_link.priority_nr%TYPE)
    IS 'This function is used to add a link to a single step of a process.';



CREATE OR REPLACE FUNCTION processes.f_remove_step_link(p_step_link_id processes.Step_link.step_link_id%TYPE)
    RETURNS VOID AS $$
DELETE
FROM processes.Step_link
WHERE step_link_id = p_step_link_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_process_link(p_process_link_id processes.Process_link.process_link_id%TYPE)
    IS 'This function is used to remove an associated link from an existing step.';

-- Decision tables

CREATE OR REPLACE FUNCTION processes.f_add_decision_table(p_action_id processes.Decision_table.action_id%TYPE,
                                                          p_name processes.Decision_table.name%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Decision_table(action_id, name)
SELECT p_action_id, p_name FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_decision_table(p_action_id processes.Decision_table.action_id%TYPE,
    p_name processes.Decision_table.name%TYPE)
    IS 'This function is used to add a decision table to a step of a process.';



CREATE OR REPLACE FUNCTION processes.f_switch_activation_decision_table(p_decision_table_id processes.Decision_table_entry.decision_table_id%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Decision_table
SET is_active = NOT is_active
WHERE decision_table_id = p_decision_table_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_switch_activation_decision_table(p_decision_table_id processes.Decision_table_entry.decision_table_id%TYPE)
    IS 'This function activates a decision table if it is deactivated and deactivates it if it activated.';



CREATE OR REPLACE FUNCTION processes.f_add_decision_table_entry(p_decision_table_id processes.Decision_table_entry.decision_table_id%TYPE,
                                                                p_condition processes.Decision_table_entry.condition%TYPE,
                                                                p_action processes.Decision_table_entry.action%TYPE,
                                                                p_seq_nr processes.Decision_table_entry.seq_nr%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Decision_table_entry(decision_table_id, condition, action, seq_nr)
SELECT p_decision_table_id, p_condition, p_action, p_seq_nr FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_decision_table_entry(p_decision_table_id processes.Decision_table_entry.decision_table_id%TYPE,
    p_condition processes.Decision_table_entry.condition%TYPE,
    p_action processes.Decision_table_entry.action%TYPE,
    p_seq_nr processes.Decision_table_entry.seq_nr%TYPE)
    IS 'This function is used to add an entry to an existing decision table.';



CREATE OR REPLACE FUNCTION processes.f_remove_decision_table(p_decision_table_id processes.Decision_table.decision_table_id%TYPE)
    RETURNS VOID AS $$
DELETE
FROM processes.Decision_table
WHERE decision_table_id = p_decision_table_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_decision_table(p_decision_table_id processes.Decision_table.decision_table_id%TYPE)
    IS 'This function is used to remove an existing decision table.';



CREATE OR REPLACE FUNCTION processes.f_remove_decision_table_entry(p_decision_table_entry_id processes.Decision_table_entry.decision_table_entry_id%TYPE)
    RETURNS VOID AS $$
DELETE
FROM processes.decision_table_entry
WHERE decision_table_entry_id = p_decision_table_entry_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_decision_table_entry(p_decision_table_entry_id processes.decision_table_entry.decision_table_entry_id%TYPE)
    IS 'This function is used to remove a decision table entry from an existing decision table.';



CREATE OR REPLACE FUNCTION processes.f_change_decision_table_entry(p_decision_table_entry_id processes.Decision_table_entry.decision_table_entry_id%TYPE,
                                                                   p_condition processes.Decision_table_entry.condition%TYPE,
                                                                   p_action processes.Decision_table_entry.action%TYPE,
                                                                   p_seq_nr processes.Decision_table_entry.seq_nr%TYPE)
    RETURNS VOID AS $$
UPDATE processes.Decision_table_entry
SET condition = p_condition,
    action    = p_action,
    seq_nr    = p_seq_nr
WHERE decision_table_entry_id = p_decision_table_entry_id;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_decision_table_entry(p_decision_table_entry_id processes.Decision_table_entry.decision_table_entry_id%TYPE,
    p_condition processes.Decision_table_entry.condition%TYPE,
    p_action processes.Decision_table_entry.action%TYPE,
    p_seq_nr processes.Decision_table_entry.seq_nr%TYPE)
    IS 'This function is used to change an existing decision table entry''s condition text, action text, and sequence number';


-- Log

CREATE OR REPLACE FUNCTION processes.f_log_process_usage(p_process_id processes.Process_usage.process_id%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Process_usage(process_id)
SELECT p_process_id FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_log_process_usage(p_process_id processes.Process_usage.process_id%TYPE)
    IS 'This function is used to log an opening of a process.';



CREATE OR REPLACE FUNCTION processes.f_log_step_click(p_process_usage_id processes.Step_click.process_usage_id%TYPE,
                                                      p_step_id processes.Step_click.step_id%TYPE)
    RETURNS VOID AS $$
INSERT INTO processes.Step_click(process_usage_id, step_id)
SELECT p_process_usage_id, p_step_id FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER
                SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_log_step_click(p_process_usage_id processes.Step_click.process_usage_id%TYPE,
    p_step_id processes.Step_click.step_id%TYPE)
    IS 'This function is used to log a chosen step.';
