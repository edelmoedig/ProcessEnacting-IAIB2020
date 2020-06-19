CREATE OR REPLACE FUNCTION processes.f_register_process() RETURNS trigger AS
$$
BEGIN
    NEW.process_status_type_code := 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_register_process() IS 'This function ensures that all processes are created with status "On hold" by setting the status code of newly created processes accordingly.';

CREATE TRIGGER trig_register_process
    BEFORE INSERT
    ON processes.Process
    FOR EACH ROW
    WHEN (NEW.process_status_type_code <> 1)
EXECUTE FUNCTION processes.f_register_process();



CREATE OR REPLACE FUNCTION processes.f_change_process_status() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Allowed status transitions are: "On hold" => "Active", "Active" => "Inactive", "Inactive" => "Active", "Active" => "Ended", "Inactive" => "Ended".';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_process_status() IS 'This function ensures that only valid transitions between process statuses ("On hold" => "Active", "Active" => "Inactive", "Inactive" => "Active", "Active" => "Ended", "Inactive" => "Ended") are allowed.';

CREATE TRIGGER trig_change_process_status
    BEFORE UPDATE OF process_status_type_code
    ON processes.Process
    FOR EACH ROW
    WHEN (NOT ((OLD.process_status_type_code = NEW.process_status_type_code) OR
               (OLD.process_status_type_code = 1 AND NEW.process_status_type_code = 2) OR
               (OLD.process_status_type_code = 2 AND NEW.process_status_type_code = 3) OR
               (OLD.process_status_type_code = 3 AND NEW.process_status_type_code = 2) OR
               (OLD.process_status_type_code IN (2, 3) AND NEW.process_status_type_code = 4)))
EXECUTE FUNCTION processes.f_change_process_status();



CREATE OR REPLACE FUNCTION processes.f_activate_process_no_valid_last_step() RETURNS trigger AS
$$
BEGIN
    IF EXISTS(SELECT action_id, process_id
              FROM processes.Action
                       INNER JOIN processes.Step ON action_id = step_id
              WHERE process_id = NEW.process_id
                AND NOT EXISTS(SELECT action_id
                               FROM processes.Action_in_parallel_activity
                               WHERE Action.action_id = Action_in_parallel_activity.action_id)
                  FOR UPDATE) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'This process does not have any valid final steps.';
    END IF;
END ;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_activate_process_no_valid_last_step() IS 'This function ensures that only processes that have at least one action that does not refer to the next step can be activated.';

CREATE TRIGGER trig_activate_process_no_valid_last_step
    BEFORE UPDATE OF process_status_type_code
    ON processes.Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> NEW.process_status_type_code AND NEW.process_status_type_code = 2)
EXECUTE FUNCTION processes.f_activate_process_no_valid_last_step();



CREATE OR REPLACE FUNCTION processes.f_activate_process_options_no_next_step() RETURNS trigger AS
$$
DECLARE
    v_count bigint;
BEGIN
    LOCK TABLE processes.Process, processes.Option, processes.Decision, processes.Step IN ACCESS EXCLUSIVE MODE;
    v_count := (SELECT COUNT(*)
                FROM (SELECT Option.next_step_id
                      FROM processes.Option
                               INNER JOIN (processes.Decision INNER JOIN (processes.Step INNER JOIN processes.Process
                          ON Step.process_id = Process.process_id)
                          ON step_id = decision_id)
                                          ON Option.decision_id = Decision.decision_id
                      WHERE Process.process_id = NEW.process_id
                        AND Option.next_step_id IS NULL) AS Option_with_no_next_step);
    IF v_count > 0 THEN
        RAISE EXCEPTION 'There are % options at the decision steps of this process
            that have no next step assigned to them. Every option must lead to the next
            step.', v_count;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_activate_process_options_no_next_step() IS 'This function ensures that only processes where every option has an associated next step can be activated.';

CREATE TRIGGER trig_activate_process_options_no_next_step
    BEFORE UPDATE OF process_status_type_code
    ON processes.Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> NEW.process_status_type_code AND NEW.process_status_type_code = 2)
EXECUTE FUNCTION processes.f_activate_process_options_no_next_step();



CREATE OR REPLACE FUNCTION processes.f_activate_process_decision_less_than_2_options() RETURNS trigger AS
$$
DECLARE
    v_count bigint;
BEGIN
    LOCK TABLE processes.Process, processes.Option, processes.Decision, processes.Step IN ACCESS EXCLUSIVE MODE;
    v_count := (SELECT Count(*)
                FROM (SELECT Decision.decision_id, count(option_id)
                      FROM processes.Decision
                               INNER JOIN processes.Step ON decision_id = step_id
                               LEFT JOIN processes.Option
                                         ON Option.decision_id =
                                            Decision.decision_id
                      WHERE Step.process_id = NEW.process_id
                      GROUP BY Decision.decision_id
                      HAVING Count(*) < 2) AS Decision_option_count);
    IF v_count > 0 THEN
        RAISE EXCEPTION 'There are % decision steps that have less than 2 options.', v_count;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_activate_process_decision_less_than_2_options() IS 'This function ensures that only processes where every decision step has at least 2 associated options can be activated.';

CREATE TRIGGER trig_activate_process_decision_less_than_2_options
    BEFORE UPDATE OF process_status_type_code
    ON processes.Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> NEW.process_status_type_code AND NEW.process_status_type_code = 2)
EXECUTE FUNCTION processes.f_activate_process_decision_less_than_2_options();



CREATE OR REPLACE FUNCTION processes.f_activate_process_parallel_activity_less_than_2_actions() RETURNS trigger AS
$$
DECLARE
    v_count bigint;
BEGIN
    LOCK TABLE processes.Process, processes.Action_in_parallel_activity, processes.Parallel_activity, processes.Step IN ACCESS EXCLUSIVE MODE;
    v_count := (SELECT Count(*)
                FROM (SELECT Parallel_activity.parallel_activity_id, count(action_id)
                      FROM processes.Parallel_activity
                               INNER JOIN processes.Step ON parallel_activity_id = step_id
                               LEFT JOIN processes.Action_in_parallel_activity
                                         ON Action_in_parallel_activity.parallel_activity_id =
                                            Parallel_activity.parallel_activity_id
                      WHERE Step.process_id = NEW.process_id
                      GROUP BY Parallel_activity.parallel_activity_id
                      HAVING Count(*) < 2) AS Parallel_action_count);
    IF v_count > 0 THEN
        RAISE EXCEPTION 'There are % parallel activities that have less than 2 parallel actions.', v_count;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_activate_process_parallel_activity_less_than_2_actions() IS 'This function ensures that only processes where every decision parallel activity has at least 2 associated actions can be activated.';

CREATE TRIGGER trig_activate_process_parallel_activity_less_than_2_actions
    BEFORE UPDATE OF process_status_type_code
    ON processes.Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> NEW.process_status_type_code AND NEW.process_status_type_code = 2)
EXECUTE FUNCTION processes.f_activate_process_parallel_activity_less_than_2_actions();



CREATE OR REPLACE FUNCTION processes.f_change_process_owner_or_reg_time() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Process''s owner and registration time cannot be changed.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_process_owner_or_reg_time() IS 'This function prevents changing a process''s owner and registration time.';

CREATE TRIGGER trig_change_process_owner_or_reg_time
    BEFORE UPDATE OF owner_id, reg_time
    ON processes.Process
    FOR EACH ROW
    WHEN (NEW.owner_id <> OLD.owner_id OR NEW.reg_time <> OLD.reg_time)
EXECUTE FUNCTION processes.f_change_process_owner_or_reg_time();



CREATE OR REPLACE FUNCTION processes.f_change_step_reg_time() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Step''s registration time cannot be changed.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_step_reg_time() IS 'This function prevents changing a process''s owner and registration time.';

CREATE TRIGGER trig_change_step_reg_time
    BEFORE UPDATE OF reg_time
    ON processes.Step
    FOR EACH ROW
    WHEN (NEW.reg_time <> OLD.reg_time)
EXECUTE FUNCTION processes.f_change_step_reg_time();



CREATE OR REPLACE FUNCTION processes.f_change_process_name_or_description() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Process''s name and description can only be changed when its status is "On hold" or "Inactive".';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_process_name_or_description() IS 'This function prevents changing the name and description of an active process.';

CREATE TRIGGER trig_change_process_name_or_description
    BEFORE UPDATE
        OF name, description
    ON processes.Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code NOT IN (1, 3) OR
          (OLD.process_status_type_code IN (1, 3) AND OLD.process_status_type_code <> NEW.process_status_type_code))
EXECUTE FUNCTION processes.f_change_process_name_or_description();



CREATE OR REPLACE FUNCTION processes.f_add_next_step_to_decision() RETURNS trigger AS
$$
BEGIN
    IF EXISTS(SELECT 1 FROM processes.Decision WHERE decision_id = NEW.step_id FOR UPDATE) THEN
        RAISE EXCEPTION 'Decision step cannot have an associated next step. The decision''s options must be linked to the next step.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_next_step_to_decision() IS 'This function prevents adding a next step to a decision.';

CREATE TRIGGER trig_add_next_step_to_decision
    BEFORE UPDATE
        OF next_step_id
    ON processes.Step
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_next_step_to_decision();



CREATE OR REPLACE FUNCTION processes.f_add_option_leading_to_action_in_parallel_activity() RETURNS trigger AS $$
BEGIN
    IF EXISTS(SELECT 1
              FROM processes.action_in_parallel_activity
              WHERE action_in_parallel_activity.action_id = NEW.next_step_id FOR UPDATE) THEN
        RAISE EXCEPTION 'Options cannot lead to action steps in parallel activity, they must lead to the parallel activity.';
    ELSE
        RETURN NEW;
    END IF;
END ;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_option_leading_to_action_in_parallel_activity() IS 'This function prevents adding options whose next step is set to an action in a parallel activity. Steps must be added to the parallel activity.';

CREATE TRIGGER trig_add_option_leading_to_action_in_parallel_activity
    BEFORE INSERT
    ON processes.Option
    FOR EACH ROW
    WHEN (NEW.next_step_id IS NOT NULL)
EXECUTE FUNCTION processes.f_add_option_leading_to_action_in_parallel_activity();



CREATE OR REPLACE FUNCTION processes.f_add_step_leading_to_action_in_parallel_activity() RETURNS trigger AS $$
BEGIN
    IF EXISTS(SELECT 1
              FROM processes.action_in_parallel_activity
              WHERE action_id = NEW.step_id FOR UPDATE) THEN
        RAISE EXCEPTION 'Steps cannot lead to action steps in parallel activity, they must lead to the parallel activity.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_step_leading_to_action_in_parallel_activity() IS 'This function prevents adding steps whose next step is set to an action in a parallel activity. Steps must be added to the parallel activity.';

CREATE TRIGGER trig_add_step_leading_to_action_in_parallel_activity
    BEFORE INSERT
    ON processes.Step
    FOR EACH ROW
    WHEN (NEW.step_id IS NOT NULL)
EXECUTE FUNCTION processes.f_add_step_leading_to_action_in_parallel_activity();



CREATE OR REPLACE FUNCTION processes.f_add_next_step_to_action_in_parallel_activity() RETURNS trigger AS $$
BEGIN
    IF EXISTS(SELECT 1
              FROM processes.action_in_parallel_activity
              WHERE action_in_parallel_activity.action_id = NEW.next_step_id FOR UPDATE) THEN
        RAISE EXCEPTION 'Steps cannot lead to action steps in parallel activity, they must lead to the parallel activity.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_next_step_to_action_in_parallel_activity() IS 'This function prevents adding next steps to actions a parallel activity. The next step must be .';

CREATE TRIGGER trig_add_next_step_to_action_in_parallel_activity
    BEFORE UPDATE OF next_step_id
    ON processes.Step
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_next_step_to_action_in_parallel_activity();



CREATE OR REPLACE FUNCTION processes.f_change_process_first_step() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Process''s first step cannot be reassigned without deleting the currently associated next step.';
END;

$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_process_first_step() IS 'This function prevents reassigning the first step of a process.';

CREATE TRIGGER trig_change_process_first_step
    BEFORE UPDATE
        OF first_step_id
    ON processes.Process
    FOR EACH ROW
    WHEN (OLD.first_step_id IS NOT NULL AND NEW.first_step_id IS NOT NULL)
EXECUTE FUNCTION processes.f_change_process_first_step();



CREATE OR REPLACE FUNCTION processes.f_change_step_next_step() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Step''s next step cannot be reassigned without deleting the currently associated next step.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_step_next_step() IS 'This function prevents reassigning the next step of a step.';

CREATE TRIGGER trig_change_step_next_step
    BEFORE UPDATE
        OF next_step_id
    ON processes.Step
    FOR EACH ROW
    WHEN (OLD.next_step_id IS NOT NULL AND NEW.next_step_id IS NOT NULL)
EXECUTE FUNCTION processes.f_change_step_next_step();



CREATE OR REPLACE FUNCTION processes.f_change_option_next_step() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Option''s next step cannot be reassigned without deleting the currently associated next step.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_change_option_next_step() IS 'This function prevents reassigning the next step of an option.';

CREATE TRIGGER trig_change_option_next_step
    BEFORE UPDATE
        OF next_step_id
    ON processes.Option
    FOR EACH ROW
    WHEN (OLD.next_step_id IS NOT NULL AND NEW.next_step_id IS NOT NULL)
EXECUTE FUNCTION processes.f_change_option_next_step();



CREATE OR REPLACE FUNCTION processes.f_forget_process() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Process can only be removed if it''s status is "On hold".';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_forget_process() IS 'This function prevents deleting of published processes.';

CREATE TRIGGER trig_forget_process
    BEFORE DELETE
    ON processes.Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> 1)
EXECUTE FUNCTION processes.f_forget_process();



CREATE OR REPLACE FUNCTION processes.f_edit_process_step() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
         WHERE Process.process_id = OLD.process_id FOR UPDATE) NOT IN
        (1, 3)) THEN
        RAISE EXCEPTION 'Process''s steps can only be edited if it''s status is "On hold" or "Inactive".';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_edit_process_step() IS 'This function prevents editing of active processes.';

CREATE TRIGGER trig_edit_process_step
    BEFORE UPDATE
    ON processes.Step
    FOR EACH ROW
EXECUTE FUNCTION processes.f_edit_process_step();



CREATE OR REPLACE FUNCTION processes.f_remove_process_step() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
         WHERE Process.process_id = OLD.process_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'Process''s steps can only be removed if it''s status is "On hold" or "Inactive".';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_process_step() IS 'This function prevents removal of steps from active processes.';

CREATE TRIGGER trig_remove_process_step
    BEFORE DELETE
    ON processes.Step
    FOR EACH ROW
EXECUTE FUNCTION processes.f_remove_process_step();



CREATE OR REPLACE FUNCTION processes.f_remove_process_step_with_next_step() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Process''s steps can only be removed if they have no associated next steps. %, %', OLD.step_id, OLD.next_step_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_process_step_with_next_step() IS 'This function prevents removal of steps with associated next steps.';

CREATE TRIGGER trig_remove_process_step_with_next_step
    AFTER DELETE
    ON processes.Step
    FOR EACH ROW
    WHEN (OLD.next_step_id IS NOT NULL)
EXECUTE FUNCTION processes.f_remove_process_step_with_next_step();



CREATE OR REPLACE FUNCTION processes.f_edit_decision_option() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
                  INNER JOIN processes.Step ON Process.process_id = Step.process_id
         WHERE Step.step_id = NEW.decision_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'Decision''s options can only be edited if its associated process''s status is "On hold" or "Inactive".';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_edit_decision_option() IS 'This function prevents editing of options associated with active processes.';

CREATE TRIGGER trig_edit_decision_option
    BEFORE UPDATE
    ON processes.Option
    FOR EACH ROW
EXECUTE FUNCTION processes.f_edit_decision_option();



CREATE OR REPLACE FUNCTION processes.f_remove_decision_option() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
                  INNER JOIN processes.Step ON Process.process_id = Step.process_id
         WHERE Step.step_id = OLD.decision_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'Decision''s options can only be removed if its associated process''s status is "On hold" or "Inactive".';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_decision_option() IS 'This function prevents removal of options associated with active and ended processes.';

CREATE TRIGGER trig_remove_decision_option
    BEFORE DELETE
    ON processes.Option
    FOR EACH ROW
EXECUTE FUNCTION processes.f_remove_decision_option();



CREATE OR REPLACE FUNCTION processes.f_remove_decision_option_with_next_step() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Decision''s options can only be removed if they have no associated next steps.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_decision_option_with_next_step() IS 'This function prevents removal of options that have an associated next step.';

CREATE TRIGGER trig_remove_decision_option_with_next_step
    BEFORE DELETE
    ON processes.Option
    FOR EACH ROW
    WHEN (OLD.next_step_id IS NOT NULL)
EXECUTE FUNCTION processes.f_remove_decision_option_with_next_step();



CREATE OR REPLACE FUNCTION processes.f_add_step() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
         WHERE Process.process_id = NEW.process_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'New steps cannot be added to active and ended processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_step() IS 'This function prevents adding steps to active and ended processes.';

CREATE TRIGGER trig_add_step
    BEFORE INSERT
    ON processes.Step
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_step();



CREATE OR REPLACE FUNCTION processes.f_add_decision_option() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
                  INNER JOIN processes.Step ON Process.process_id = Step.process_id
         WHERE Step.step_id = NEW.decision_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'New options cannot be added at decision steps of active and ended processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_decision_option() IS 'This function prevents adding options associated with active and ended processes.';

CREATE TRIGGER trig_add_decision_option
    BEFORE INSERT
    ON processes.Option
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_decision_option();



CREATE OR REPLACE FUNCTION processes.f_add_process_link() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
         WHERE Process.process_id = NEW.process_id FOR UPDATE) NOT IN
        (1, 3)) THEN
        RAISE EXCEPTION 'New process links cannot be added to active and ended processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_process_link() IS 'This function prevents adding new links to active and ended processes.';

CREATE TRIGGER trig_add_process_link
    BEFORE INSERT
    ON processes.Process_link
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_process_link();



CREATE OR REPLACE FUNCTION processes.f_remove_process_link() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
         WHERE Process.process_id = OLD.process_id FOR UPDATE) NOT IN
        (1, 3)) THEN
        RAISE EXCEPTION 'Process links cannot be removed from active and ended processes.';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_process_link() IS 'This function prevents removing existing links from active and ended processes.';

CREATE TRIGGER trig_remove_process_link
    BEFORE DELETE
    ON processes.Process_link
    FOR EACH ROW
EXECUTE FUNCTION processes.f_remove_process_link();



CREATE OR REPLACE FUNCTION processes.f_edit_process_link() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
         WHERE Process.process_id = OLD.process_id FOR UPDATE) NOT IN
        (1, 3)) THEN
        RAISE EXCEPTION 'Process links associated with active and ended processes cannot be edited.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_edit_process_link() IS 'This function prevents editing existing process links of active and ended processes.';

CREATE TRIGGER trig_edit_process_link
    BEFORE UPDATE
    ON processes.Process_link
    FOR EACH ROW
EXECUTE FUNCTION processes.f_edit_process_link();



CREATE OR REPLACE FUNCTION processes.f_add_step_link() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
                  INNER JOIN Step ON Process.process_id = Step.process_id
         WHERE Step.step_id = NEW.step_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'New project links cannot be added to the steps of active and ended processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_step_link() IS 'This function prevents adding new links to the steps of active and ended processes.';

CREATE TRIGGER trig_add_step_link
    BEFORE INSERT
    ON processes.Step_link
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_step_link();



CREATE OR REPLACE FUNCTION processes.f_remove_step_link() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
                  INNER JOIN Step ON Process.process_id = Step.process_id
         WHERE Step.step_id = OLD.step_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'Step links cannot be removed from active and ended processes.';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_step_link() IS 'This function prevents removing existing links from the steps of active and ended processes.';

CREATE TRIGGER trig_remove_step_link
    BEFORE DELETE
    ON processes.Step_link
    FOR EACH ROW
EXECUTE FUNCTION processes.f_remove_step_link();



CREATE OR REPLACE FUNCTION processes.f_edit_step_link() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM processes.Process
                  INNER JOIN Step ON Process.process_id = Step.process_id
         WHERE Step.step_id = NEW.step_id FOR UPDATE) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'Step links associated with active and ended processes cannot be edited.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_edit_step_link() IS 'This function prevents editing existing step links of active and ended processes.';

CREATE TRIGGER trig_edit_step_link
    BEFORE UPDATE
    ON processes.Step_link
    FOR EACH ROW
EXECUTE FUNCTION processes.f_edit_step_link();



CREATE OR REPLACE FUNCTION processes.f_add_decision_table() RETURNS trigger AS $$
BEGIN
    IF (SELECT process_status_type_code
        FROM processes.Decision_table
                 INNER JOIN
             (processes.Step INNER JOIN processes.Process ON Step.process_id = Process.process_id)
             ON Decision_table.action_id = Step.step_id
        WHERE Decision_table.decision_table_id = NEW.decision_table_id FOR UPDATE) NOT IN (1, 3) THEN
        RAISE EXCEPTION 'Decision tables cannot be added to active and ended processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_decision_table() IS 'This function prevents adding new decision tables to the steps of active and ended processes.';

CREATE TRIGGER trig_add_decision_table
    BEFORE INSERT
    ON processes.Decision_table
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_decision_table();



CREATE OR REPLACE FUNCTION processes.f_remove_decision_table() RETURNS trigger AS $$
BEGIN
    IF (SELECT process_status_type_code
        FROM processes.Decision_table
                 INNER JOIN
             (processes.Step INNER JOIN processes.Process ON Step.process_id = Process.process_id)
             ON Decision_table.action_id = Step.step_id
        WHERE Decision_table.decision_table_id = OLD.decision_table_id FOR UPDATE) NOT IN (1, 3) THEN
        RAISE EXCEPTION 'Decision tables cannot be removed from active and ended processes.';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_decision_table() IS 'This function prevents removing existing links from the steps of active and ended processes.';

CREATE TRIGGER trig_remove_decision_table
    BEFORE DELETE
    ON processes.Decision_table
    FOR EACH ROW
EXECUTE FUNCTION processes.f_remove_decision_table();



CREATE OR REPLACE FUNCTION processes.f_edit_decision_table() RETURNS trigger AS $$
BEGIN
    IF (SELECT process_status_type_code
        FROM processes.Decision_table
                 INNER JOIN
             (processes.Step INNER JOIN processes.Process ON Step.process_id = Process.process_id)
             ON Decision_table.action_id = Step.step_id
        WHERE Decision_table.decision_table_id = NEW.decision_table_id FOR UPDATE) NOT IN (1, 3) THEN
        RAISE EXCEPTION 'Decision tables of active and ended processes cannot be edited.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_edit_decision_table() IS 'This function prevents editing of decision tables asssociated with active and ended processes.';

CREATE TRIGGER trig_edit_decision_table
    BEFORE UPDATE
    ON processes.Decision_table
    FOR EACH ROW
EXECUTE FUNCTION processes.f_edit_decision_table();



CREATE OR REPLACE FUNCTION processes.f_add_decision_table_entry() RETURNS trigger AS $$
BEGIN
    IF (SELECT process_status_type_code
        FROM processes.Decision_table
                 INNER JOIN
             (processes.Step INNER JOIN processes.Process ON Step.process_id = Process.process_id)
             ON Decision_table.action_id = Step.step_id
        WHERE Decision_table.decision_table_id = NEW.decision_table_id FOR UPDATE) NOT IN (1, 3) THEN
        RAISE EXCEPTION 'New entries cannot be added to decision tables active and ended processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_add_decision_table_entry() IS 'This function prevents adding new decision table entries associated with active and ended processes.';

CREATE TRIGGER trig_add_decision_table_entry
    BEFORE INSERT
    ON processes.Decision_table_entry
    FOR EACH ROW
EXECUTE FUNCTION processes.f_add_decision_table_entry();



CREATE OR REPLACE FUNCTION processes.f_remove_decision_table_entry() RETURNS trigger AS $$
BEGIN
    IF (SELECT process_status_type_code
        FROM processes.Decision_table
                 INNER JOIN
             (processes.Step INNER JOIN processes.Process ON Step.process_id = Process.process_id)
             ON Decision_table.action_id = Step.step_id
        WHERE Decision_table.decision_table_id = OLD.decision_table_id FOR UPDATE) NOT IN (1, 3) THEN
        RAISE EXCEPTION 'Decision table entries cannot be removed from decision tables of active and ended processes.';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_remove_decision_table_entry() IS 'This function prevents removing table entries from decision tables associated with active and ended processes.';

CREATE TRIGGER trig_remove_decision_table_entry
    BEFORE DELETE
    ON processes.Decision_table_entry
    FOR EACH ROW
EXECUTE FUNCTION processes.f_remove_decision_table_entry();



CREATE OR REPLACE FUNCTION processes.f_edit_decision_table_entry() RETURNS trigger AS $$
BEGIN
    IF (SELECT process_status_type_code
        FROM processes.Decision_table
                 INNER JOIN
             (processes.Step INNER JOIN processes.Process ON Step.process_id = Process.process_id)
             ON Decision_table.action_id = Step.step_id
        WHERE Decision_table.decision_table_id = NEW.decision_table_id FOR UPDATE) NOT IN (1, 3) THEN
        RAISE EXCEPTION 'Decision table entries associated with the decision tables of active and ended processes cannot be edited.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = processes, public, pg_temp;

COMMENT ON FUNCTION processes.f_edit_decision_table_entry() IS 'This function prevents editing table entries of decision tables associated with active and ended processes.';

CREATE TRIGGER trig_edit_decision_table_entry
    BEFORE UPDATE
    ON processes.Decision_table_entry
    FOR EACH ROW
EXECUTE FUNCTION processes.f_edit_decision_table_entry();
