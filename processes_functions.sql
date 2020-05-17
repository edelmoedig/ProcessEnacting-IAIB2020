CREATE OR REPLACE FUNCTION f_register_administrator(p_email Administrator.email%TYPE, p_password Administrator.password%TYPE, p_given_name Administrator.given_name%TYPE, p_surname Administrator.surname%TYPE)
RETURNS VOID AS $$
INSERT INTO Administrator(email, password, given_name, surname)
SELECT p_email, p_password, p_given_name, p_surname FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_register_administrator(p_email Administrator.email%TYPE, p_password Administrator.password%TYPE, p_given_name Administrator.given_name%TYPE, p_surname Administrator.surname%TYPE) IS "This function is used to register a new process administrator.";

CREATE OR REPLACE FUNCTION f_register_process(p_name Process.name. p_description Process.description, p_owner Process.owner_id%TYPE, p_password Process.password%TYPE)
RETURNS VOID AS $$
INSERT INTO Process(name, description, owner_id, password)
SELECT p_name, p_description, p_owner, p_password FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_register_process(p_name Process.name. p_description Process.description, p_owner Process.owner_id%TYPE, p_password Process.password%TYPE) IS "This function is used to register a new process.";

CREATE OR REPLACE FUNCTION f_add_action(p_process_id Step.process_id%TYPE, p_description Step.description%TYPE)
RETURNS VOID AS $$
BEGIN
INSERT INTO Step(process_id, description) VALUES (p_process_id. p_description);
INSERT INTO Action(action_id) VALUES (currval('step_id_seq'));
END;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_action(p_process_id Step.process_id%TYPE, p_description Step.description%TYPE) IS "This function is used to add a new acton step to an existing process.";

CREATE OR REPLACE FUNCTION f_add_parallel_activity(p_process_id Step.process_id%TYPE, p_description Step.description%TYPE)
RETURNS VOID AS $$
BEGIN
INSERT INTO Step(process_id, description) VALUES (p_process_id. p_description);
INSERT INTO Parallel_activity(parallel_activity_id) VALUES (currval('step_id_seq'));
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_parallel_activity(p_process_id Step.process_id%TYPE, p_description) IS "This function is used to add a new parallel activity to an existing process.";

CREATE OR REPLACE FUNCTION f_add_action_in_parallel_activity(p_process_id Step.process_id%TYPE, p_parallel_activity_id Parallel_activity.parallel_activity_id%TYPE, p_description Step.description%TYPE)
RETURNS VOID AS $$
BEGIN
INSERT INTO Step(process_id, description) VALUES (p_process_id. p_description);
INSERT INTO Action_in_parallel_activity(parallel_activity_id, action_id) VALUES (p_parallel_activity_id, currval('step_id_seq'));
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_action_in_parallel_activity(p_process_id Step.process_id%TYPE, p_parallel_activity_id Parallel_activity.parallel_activity_id%TYPE, p_description Step.description%TYPE) IS "This function is used to add a new action to an existing parallel activity in an existing process.";

CREATE OR REPLACE FUNCTION f_add_decision(p_process_id Step.process_id%TYPE, p_description Step.description%TYPE)
RETURNS VOID AS $$
BEGIN
INSERT INTO Step(process_id, description) VALUES (p_process_id. p_description);
INSERT INTO Decision(decision_id) VALUES (currval('step_id_seq'));
END;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_decision(p_process_id Step.process_id%TYPE, p_description Step.description%TYPE) IS "This function is used to add a new decision step to an existing process.";

CREATE OR REPLACE FUNCTION f_add_option_to_decision(p_decision_id Variant.decision_id%TYPE, p_weight Variant.weight%TYPE, p_guard Variant.guard%TYPE)
RETURNS VOID AS $$
INSERT INTO Variant(decision_id, weight, guard) VALUES (p_decision_id, p_weight, p_guard);
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_option_to_decision(p_decision_id Variant.decision_id%TYPE, p_weight Variant.weight%TYPE, p_guard Variant.guard%TYPE) IS "This function is used to add an option to an existing decision step.";

CREATE OR REPLACE FUNCTION f_add_process_link(p_process_id Process_link.process_id%TYPE, p_url Process_link.url%TYPE, p_name Process_link.name%TYPE, p_priority_nr Process_link.priority_nr%TYPE)
RETURNS VOID AS $$
INSERT INTO Process_link(process_id, url, name, priority_nr)
SELECT p_process_id, p_url, p_name, p_priority_nr FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_process_link(p_process_id Process_link.process_id%TYPE, p_url Process_link.url%TYPE, p_name Process_link.name%TYPE, p_priority_nr Process_link.priority_nr%TYPE) IS "This function is used to add a link to a process in general.";

CREATE OR REPLACE FUNCTION f_add_step_link(p_step_id Step_link.step_id%TYPE, p_url Step_link.url%TYPE, p_name Step_link.name%TYPE, p_priority_nr Step_link.priority_nr%TYPE)
RETURNS VOID AS $$
INSERT INTO Step_link(process_id, url, name, priority_nr)
SELECT p_process_id, p_url, p_name, p_priority_nr FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_step_link(p_step_id Step_link.step_id%TYPE, p_url Step_link.url%TYPE, p_name Step_link.name%TYPE, p_priority_nr Step_link.priority_nr%TYPE) IS "This function is used to add a link to a single step of a process.";

CREATE OR REPLACE FUNCTION f_add_decision_table(p_action_id Decision_table.action_id%TYPE, p_name Decision_table.name%TYPE)
RETURNS VOID AS $$
INSERT INTO Decision_table(action_id, name)
SELECT p_action_id, p_name FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_decision_table(p_action_id Decision_table.action_id%TYPE, p_name Decision_table.name%TYPE) IS "This function is used to add a decision table to a step of a process.";

CREATE OR REPLACE FUNCTION f_add_decision_table_entry(p_decision_table_id Decision_table_entry.decision_table_id%TYPE, p_condition Decision_table_entry.condition%TYPE, p_action Decision_table_entry.action%TYPE, p_seq_nr Decision_table_entry.seq_nr%TYPE)
RETURNS VOID AS $$
INSERT INTO Decision_table_entry(decision_table_id, condtition, action, seq_nr)
SELECT p_decision_table_id, p_condition, p_action, p_seq_nr FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_decision_table_entry(p_decision_table_id Decision_table_entry.decision_table_id%TYPE, p_condition Decision_table_entry.condition%TYPE, p_action Decision_table_entry.action%TYPE, p_seq_nr Decision_table_entry.seq_nr%TYPE) IS "This function is used to add an entry to an existing decision table.";

CREATE OR REPLACE FUNCTION f_log_process_usage(p_process_id Process_usage.process_id%TYPE)
RETURNS VOID AS $$
INSERT INTO Process_usage(process_id)
SELECT p_process_id FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_log_process_usage(p_process_id Process_usage.process_id%TYPE) IS "This function is used to log an opening of a process.";

CREATE OR REPLACE FUNCTION f_log_step_click(p_process_usage_id Step_click.process_usage_id%TYPE, p_step_id Step_click.step_id%TYPE)
RETURNS VOID AS $$
INSERT INTO Step_click(process_usage_id, step_id)
SELECT p_process_usage_id, p_step_id FOR UPDATE;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_log_step_click(p_process_usage_id Step_click.process_usage_id%TYPE, p_step_id Step_click.step_id%TYPE) IS "This function is used to log a chosen step.";