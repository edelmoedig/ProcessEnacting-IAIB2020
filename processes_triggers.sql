CREATE OR REPLACE FUNCTION f_register_process() RETURNS trigger AS
$$
BEGIN
    NEW.process_status_type_code := 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_register_process() IS 'This function ensures that all processes are created with status "On hold" by setting the status code of newly created processes accordingly.';

CREATE TRIGGER trig_register_process
    BEFORE INSERT
    ON Process
    FOR EACH ROW
    WHEN (NEW.process_status_type_code <> 1)
EXECUTE FUNCTION f_register_process();



CREATE OR REPLACE FUNCTION f_change_process_status() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Allowed status transitions are: "On hold" => "Active", "Active" => "Inactive", "Inactive" => "Active", "Active" => "Ended", "Inactive" => "Ended".';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_change_process_status() IS 'This function ensures that only valid transitions between process statuses ("On hold" => "Active", "Active" => "Inactive", "Inactive" => "Active", "Active" => "Ended", "Inactive" => "Ended") are allowed.';

CREATE TRIGGER trig_change_process_status
    BEFORE UPDATE OF process_status_type_code
    ON Process
    FOR EACH ROW
    WHEN (NOT ((OLD.process_status_type_code = NEW.process_status_type_code) OR
               (OLD.process_status_type_code = 1 AND NEW.process_status_type_code = 2) OR
               (OLD.process_status_type_code = 2 AND NEW.process_status_type_code = 3) OR
               (OLD.process_status_type_code = 3 AND NEW.process_status_type_code = 2) OR
               (OLD.process_status_type_code IN (2, 3) AND NEW.process_status_type_code = 4)))
EXECUTE FUNCTION f_change_process_status();



CREATE OR REPLACE FUNCTION f_activate_process_options_no_next_step() RETURNS trigger AS
$$
DECLARE
    v_count bigint;
BEGIN
    v_count := (SELECT COUNT(*)
              FROM (SELECT Option.next_step_id
                    FROM Option
                             INNER JOIN (Decision INNER JOIN (Step INNER JOIN Process
                        ON Step.process_id = Process.process_id)
                        ON step_id = decision_id)
                                        ON Option.decision_id = Decision.decision_id
                    WHERE Option.next_step_id IS NULL) AS Option_with_no_next_step);
    IF v_count > 0 THEN
        RAISE EXCEPTION 'There are % options at the decision steps of this process
        that have no next step assigned to them. Every option must lead to the next
        step.', v_count;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_activate_process_options_no_next_step() IS 'This function ensures that only processes where every option has an associated next step can be activated.';

CREATE TRIGGER trig_activate_process_options_no_next_step
    BEFORE UPDATE OF process_status_type_code
    ON Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> NEW.process_status_type_code AND NEW.process_status_type_code = 2)
EXECUTE FUNCTION f_activate_process_options_no_next_step();



CREATE OR REPLACE FUNCTION f_activate_process_decision_less_than_2_options() RETURNS trigger AS
$$
DECLARE
    v_count bigint;
BEGIN
    v_count := (SELECT Count(*)
              FROM (SELECT Decision.decision_id, Count(*)
                    FROM Option
                             INNER JOIN (Decision INNER JOIN (Step INNER JOIN Process
                        ON Step.process_id = Process.process_id)
                        ON step_id = decision_id)
                                        ON Option.decision_id = Decision.decision_id
                    GROUP BY Decision.decision_id
                    HAVING Count(*) < 2) AS Decision_option_count);
    IF v_count > 0 THEN
        RAISE EXCEPTION 'There are % decision steps that have less than 2 options.', v_count;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_activate_process_decision_less_than_2_options() IS 'This function ensures that only processes where every decision step has at least 2 associated options can be activated.';

CREATE TRIGGER trig_activate_process_decision_less_than_2_options
    BEFORE UPDATE OF process_status_type_code
    ON Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> NEW.process_status_type_code AND NEW.process_status_type_code = 2)
EXECUTE FUNCTION f_activate_process_options_no_next_step();



CREATE OR REPLACE FUNCTION f_change_process_owner_or_reg_time() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Process''s owner and registration time cannot be changed.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_change_process_owner_or_reg_time() IS 'This function prevents changing a process''s owner and registration time.';

CREATE TRIGGER trig_change_process_owner_or_reg_time
    BEFORE UPDATE OF owner_id, reg_time
    ON Process
    FOR EACH ROW
    WHEN (NEW.owner_id <> OLD.owner_id OR NEW.reg_time <> OLD.reg_time)
EXECUTE FUNCTION f_change_process_owner_or_reg_time();



CREATE OR REPLACE FUNCTION f_change_step_reg_time() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Step''s registration time cannot be changed.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_change_step_reg_time() IS 'This function prevents changing a process''s owner and registration time.';

CREATE TRIGGER trig_change_step_reg_time
    BEFORE UPDATE OF reg_time
    ON Step
    FOR EACH ROW
    WHEN (NEW.reg_time <> OLD.reg_time)
EXECUTE FUNCTION f_change_step_reg_time();



CREATE OR REPLACE FUNCTION f_change_process_name_or_description() RETURNS trigger AS
$$
BEGIN
    RAISE EXCEPTION 'Process''s name and description can only be changed when its status is "On hold" or "Inactive".';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_change_process_name_or_description() IS 'This function prevents changing the name and description of an active process.';

CREATE TRIGGER trig_change_process_name_or_description
    BEFORE UPDATE
        OF name, description
    ON Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code NOT IN (1, 3) OR
          (OLD.process_status_type_code IN (1, 3) AND OLD.process_status_type_code <> NEW.process_status_type_code))
EXECUTE FUNCTION f_change_process_name_or_description();



CREATE OR REPLACE FUNCTION f_add_next_step_to_decision() RETURNS trigger AS
$$
BEGIN
    IF EXISTS(SELECT 1 FROM Decision WHERE decision_id = NEW.step_id) THEN
        RAISE EXCEPTION 'Decision step cannot have an associated next step. The decision''s options must be linked to the next step.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_next_step_to_decision() IS 'This function prevents adding a next step to a decision.';

CREATE TRIGGER trig_add_next_step_to_decision
    BEFORE UPDATE
        OF next_step_id
    ON Step
    FOR EACH ROW
EXECUTE FUNCTION f_add_next_step_to_decision();



CREATE OR REPLACE FUNCTION f_change_process_first_step() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Process''s first step cannot be reassigned without deleting the currently associated next step.';
END;

$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_change_process_first_step() IS 'This function prevents reassigning the first step of a process.';

CREATE TRIGGER trig_change_process_next_step
    BEFORE UPDATE
        OF first_step_id
    ON Process
    FOR EACH ROW
    WHEN (OLD.first_step_id IS NOT NULL AND NEW.first_step_id IS NOT NULL)
EXECUTE FUNCTION f_change_process_first_step();



CREATE OR REPLACE FUNCTION f_change_step_next_step() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Step''s next step cannot be reassigned without deleting the currently associated next step.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_change_step_next_step() IS 'This function prevents reassigning the next step of a step.';

CREATE TRIGGER trig_change_step_next_step
    BEFORE UPDATE
        OF next_step_id
    ON Step
    FOR EACH ROW
    WHEN (OLD.next_step_id IS NOT NULL AND NEW.next_step_id IS NOT NULL)
EXECUTE FUNCTION f_change_process_first_step();



CREATE OR REPLACE FUNCTION f_forget_process() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Process can only be removed if it''s status is "On hold".';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_forget_process() IS 'This function prevents deleting of published processes.';

CREATE TRIGGER trig_forget_process
    BEFORE DELETE
    ON Process
    FOR EACH ROW
    WHEN (OLD.process_status_type_code <> 1)
EXECUTE FUNCTION f_forget_process();



CREATE OR REPLACE FUNCTION f_edit_process_step() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code FROM Process WHERE Process.process_id = OLD.process_id) NOT IN
        (1, 3)) THEN
        RAISE EXCEPTION 'Process''s steps can only be edited if it''s status is "On hold" or "Inactive".';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_edit_process_step() IS 'This function prevents editing of active processes.';

CREATE TRIGGER trig_edit_process_step
    BEFORE UPDATE
    ON Step
    FOR EACH ROW
EXECUTE FUNCTION f_edit_process_step();



CREATE FUNCTION f_remove_process_step() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code FROM Process WHERE Process.process_id = OLD.process_id) <> 1) THEN
        RAISE EXCEPTION 'Process''s steps can only be removed if it''s status is "On hold".';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_remove_process_step() IS 'This function prevents removal of steps from published processes.';

CREATE TRIGGER trig_remove_process_step
    BEFORE DELETE
    ON Step
    FOR EACH ROW
EXECUTE FUNCTION f_remove_process_step();



CREATE FUNCTION f_edit_decision_option() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM Process
                  INNER JOIN (Option INNER JOIN (Decision INNER JOIN Step ON Decision.decision_id = Step.step_id) ON OLD.decision_id = Decision.decision_id)
                             ON Process.process_id = Step.process_id) NOT IN (1, 3)) THEN
        RAISE EXCEPTION 'Decision''s options can only be edited if its associated process''s status is "On hold" or "Inactive".';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_edit_decision_option() IS 'This function prevents editing of options associated with active processes.';

CREATE TRIGGER trig_edit_decision_option
    BEFORE UPDATE
    ON Option
    FOR EACH ROW
EXECUTE FUNCTION f_edit_decision_option();



CREATE FUNCTION f_remove_decision_option() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM Process
                  INNER JOIN (Option INNER JOIN (Decision INNER JOIN Step ON Decision.decision_id = Step.step_id) ON OLD.decision_id = Decision.decision_id)
                             ON Process.process_id = Step.process_id) <> 1) THEN
        RAISE EXCEPTION 'Decision''s options can only be removed if its associated process''s status is "On hold".';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_remove_decision_option() IS 'This function prevents removal of options associated with published processes.';

CREATE TRIGGER trig_remove_decision_option
    BEFORE DELETE
    ON Option
    FOR EACH ROW
EXECUTE FUNCTION f_remove_decision_option();



CREATE FUNCTION f_add_step() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code FROM Process WHERE Process.process_id = NEW.process_id) <> 1) THEN
        RAISE EXCEPTION 'New steps cannot be added to published processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_step() IS 'This function prevents adding steps to published processes.';

CREATE TRIGGER trig_add_step
    BEFORE INSERT
    ON Step
    FOR EACH ROW
EXECUTE FUNCTION f_add_step();



CREATE FUNCTION f_add_option() RETURNS trigger AS $$
BEGIN
    IF ((SELECT Process.process_status_type_code
         FROM Process
                  INNER JOIN (Option INNER JOIN (Decision INNER JOIN Step ON Decision.decision_id = Step.step_id) ON NEW.decision_id = Decision.decision_id)
                             ON Process.process_id = Step.process_id) <> 1) THEN
        RAISE EXCEPTION 'New options cannot be added at decision steps of published processes.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
                    SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_add_option() IS 'This function prevents adding options associated with published processes.';

CREATE TRIGGER trig_add_option
    BEFORE INSERT
    ON Option
    FOR EACH ROW
EXECUTE FUNCTION f_add_option();
