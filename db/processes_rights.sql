CREATE USER process_administrator;
CREATE USER process_user;

-- Revoke rights

REVOKE CONNECT, TEMP ON DATABASE processes FROM PUBLIC;

REVOKE CREATE, USAGE ON SCHEMA public FROM PUBLIC;
REVOKE CREATE, USAGE ON SCHEMA processes FROM PUBLIC;
REVOKE USAGE ON LANGUAGE plpgsql FROM PUBLIC;

REVOKE EXECUTE ON ROUTINE processes.f_activate_process(p_process_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_login_get_administrator_id(p_email character varying, p_password character varying) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_access_process_with_password(p_process_id integer, p_password character varying) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_action_in_parallel_activity(p_process_id integer, p_parallel_activity_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_action_to_option(p_process_id integer, p_option_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_action_to_option_existing_next(p_process_id integer, p_option_id integer, p_next_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_action_to_step(p_process_id integer, p_previous_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_action_to_step_existing_next(p_process_id integer, p_previous_step_id integer, p_next_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_decision_table(p_action_id integer, p_name character varying) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_decision_table_entry(p_decision_table_id integer, p_condition text, p_action text, p_seq_nr smallint) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_decision_to_option(p_process_id integer, p_option_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_decision_to_option_existing_next(p_process_id integer, p_option_id integer, p_next_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_decision_to_step(p_process_id integer, p_previous_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_decision_to_step_existing_next(p_process_id integer, p_previous_step_id integer, p_next_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_first_action(p_process_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_first_decision(p_process_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_first_parallel_activity(p_process_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_option_to_decision(p_decision_id integer, p_weight numeric, p_guard text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_option_to_decision_existing_next(p_decision_id integer, p_next_step_id integer, p_weight numeric, p_guard text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_option(p_process_id integer, p_option_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_option_existing_next(p_process_id integer, p_option_id integer, p_next_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_step(p_process_id integer, p_previous_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_step_existing_next(p_process_id integer, p_previous_step_id integer, p_next_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_process_link(p_process_id integer, p_url processes.Process_link.url%TYPE, p_name character varying, p_priority_nr smallint) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_add_step_link(p_step_id integer, p_url processes.Step_link.url%TYPE, p_name character varying, p_priority_nr smallint) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_decision_table_entry(p_decision_table_entry_id integer, p_condition text, p_action text, p_seq_nr smallint) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_process_name_and_description(p_process_id integer, p_name character varying, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_option_weight_and_guard(p_option_id integer, p_guard text, p_weight numeric) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_process_password(p_process_id integer, p_password character varying) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_step_description(p_step_id integer, p_description text) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_deactivate_process(p_process_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_end_process(p_process_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_forget_process(p_process_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_log_process_usage(p_process_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_log_step_click(p_process_usage_id bigint, p_step_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_register_administrator(p_email character varying, p_password character varying, p_given_name character varying, p_surname character varying) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_register_process(p_name character varying, p_description text, p_owner integer, p_password character varying) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_remove_decision_table(p_decision_table_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_remove_decision_table_entry(p_decision_table_entry_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_remove_option_from_decision(p_option_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_remove_process_link(p_process_link_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_remove_step(p_step_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_remove_step_link(p_step_link_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_switch_activation_decision_table(p_decision_table_id integer) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_decision_table_name(p_decision_table_id integer, p_name character varying) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_edit_process_link(p_process_link_id integer, p_url processes.Process_link.url%TYPE, p_name character varying, p_priority_nr smallint) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_edit_step_link(p_step_link_id integer, p_url processes.Step_link.url%TYPE, p_name character varying, p_priority_nr smallint) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_step_next_step(p_current_step_id processes.Step.step_id%TYPE, p_next_step_id processes.Step.step_id%TYPE) FROM PUBLIC;
REVOKE EXECUTE ON ROUTINE processes.f_change_option_next_step(p_current_option_id processes.Option.option_id%TYPE, p_next_step_id processes.Step.step_id%TYPE) FROM PUBLIC;

REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA processes FROM PUBLIC;

REVOKE USAGE ON DOMAIN processes.d_time FROM PUBLIC;


-- Grant rights

GRANT CONNECT ON DATABASE processes TO process_administrator;
GRANT CONNECT ON DATABASE processes TO process_user;

GRANT USAGE ON SCHEMA processes TO process_administrator;
GRANT USAGE ON SCHEMA processes TO process_user;

GRANT EXECUTE ON ROUTINE processes.f_activate_process(p_process_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_login_get_administrator_id(p_email character varying, p_password character varying) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_access_process_with_password(p_process_id integer, p_password character varying) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_action_in_parallel_activity(p_process_id integer, p_parallel_activity_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_action_to_option(p_process_id integer, p_option_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_action_to_option_existing_next(p_process_id integer, p_option_id integer, p_next_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_action_to_step(p_process_id integer, p_previous_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_action_to_step_existing_next(p_process_id integer, p_previous_step_id integer, p_next_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_decision_table(p_action_id integer, p_name character varying) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_decision_table_entry(p_decision_table_id integer, p_condition text, p_action text, p_seq_nr smallint) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_decision_to_option(p_process_id integer, p_option_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_decision_to_option_existing_next(p_process_id integer, p_option_id integer, p_next_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_decision_to_step(p_process_id integer, p_previous_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_decision_to_step_existing_next(p_process_id integer, p_previous_step_id integer, p_next_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_first_action(p_process_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_first_decision(p_process_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_first_parallel_activity(p_process_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_option_to_decision(p_decision_id integer, p_weight numeric, p_guard text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_option_to_decision_existing_next(p_decision_id integer, p_next_step_id integer, p_weight numeric, p_guard text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_option(p_process_id integer, p_option_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_option_existing_next(p_process_id integer, p_option_id integer, p_next_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_step(p_process_id integer, p_previous_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_parallel_activity_to_step_existing_next(p_process_id integer, p_previous_step_id integer, p_next_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_process_link(p_process_id integer, p_url processes.Process_link.url%TYPE, p_name character varying, p_priority_nr smallint) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_add_step_link(p_step_id integer, p_url processes.Step_link.url%TYPE, p_name character varying, p_priority_nr smallint) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_decision_table_entry(p_decision_table_entry_id integer, p_condition text, p_action text, p_seq_nr smallint) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_process_name_and_description(p_process_id integer, p_name character varying, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_option_weight_and_guard(p_option_id integer, p_guard text, p_weight numeric) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_process_password(p_process_id integer, p_password character varying) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_step_description(p_step_id integer, p_description text) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_deactivate_process(p_process_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_end_process(p_process_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_forget_process(p_process_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_log_process_usage(p_process_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_log_step_click(p_process_usage_id bigint, p_step_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_register_administrator(p_email character varying, p_password character varying, p_given_name character varying, p_surname character varying) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_register_process(p_name character varying, p_description text, p_owner integer, p_password character varying) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_remove_decision_table(p_decision_table_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_remove_decision_table_entry(p_decision_table_entry_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_remove_option_from_decision(p_option_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_remove_process_link(p_process_link_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_remove_step(p_step_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_remove_step_link(p_step_link_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_switch_activation_decision_table(p_decision_table_id integer) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_decision_table_name(p_decision_table_id integer, p_name character varying) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_edit_process_link(p_process_link_id integer, p_url processes.Process_link.url%TYPE, p_name character varying, p_priority_nr smallint) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_edit_step_link(p_step_link_id integer, p_url processes.Step_link.url%TYPE, p_name character varying, p_priority_nr smallint) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_step_next_step(p_current_step_id processes.Step.step_id%TYPE, p_next_step_id processes.Step.step_id%TYPE) TO process_administrator;
GRANT EXECUTE ON ROUTINE processes.f_change_option_next_step(p_current_option_id processes.Option.option_id%TYPE, p_next_step_id processes.Step.step_id%TYPE) TO process_administrator;



GRANT EXECUTE ON ROUTINE processes.f_register_administrator(p_email character varying, p_password character varying, p_given_name character varying, p_surname character varying) TO process_user;
GRANT EXECUTE ON ROUTINE processes.f_log_process_usage(p_process_id integer) TO process_user;
GRANT EXECUTE ON ROUTINE processes.f_log_step_click(p_process_usage_id bigint, p_step_id integer) TO process_user;
GRANT EXECUTE ON ROUTINE processes.f_login_get_administrator_id(p_email character varying, p_password character varying) TO process_user;
GRANT EXECUTE ON ROUTINE processes.f_access_process_with_password(p_process_id integer, p_password character varying) TO process_user;

GRANT SELECT ON
    processes.all_processes,
    processes.active_inactive_on_hold_processes,
    processes.active_processes,
    processes.process_steps,
    processes.decision_options,
    processes.decision_tables,
    processes.decision_table_entries,
    processes.process_links,
    processes.step_links,
    processes.parallel_actions
    TO process_administrator;

GRANT SELECT ON
    processes.all_processes,
    processes.active_inactive_on_hold_processes,
    processes.active_processes,
    processes.process_steps,
    processes.decision_options,
    processes.decision_tables,
    processes.decision_table_entries,
    processes.process_links,
    processes.step_links,
    processes.parallel_actions
    TO process_user;
