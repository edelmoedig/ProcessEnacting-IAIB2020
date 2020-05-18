CREATE OR REPLACE FUNCTION f_register_process() RETURNS trigger AS $$
BEGIN
    NEW.process_status_type_code := 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path=public, pg_temp;

COMMENT ON FUNCTION f_register_process() IS 'This function ensures that all processes are created with status "On hold" by setting the status code of newly created processes accordingly.';

CREATE TRIGGER trig_register_process BEFORE INSERT ON Process
FOR EACH ROW WHEN (NEW.process_status_type_code <> 1)
EXECUTE FUNCTION f_register_process();


CREATE OR REPLACE FUNCTION f_change_process_status() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Allowed status transitions are: "On hold" => "Active", "Active" => "Inactive", "Inactive" => "Active", "Active" => "Ended", "Inactive" => "Ended".';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path=public, pg_temp;

COMMENT ON FUNCTION f_change_process_status() IS 'This function ensures that only valid transitions between process statuses ("On hold" => "Active", "Active" => "Inactive", "Inactive" => "Active", "Active" => "Ended", "Inactive" => "Ended") are allowed.';

CREATE TRIGGER trig_change_process_status BEFORE UPDATE OF process_status_type_code ON Process
FOR EACH ROW WHEN (NOT ((OLD.process_status_type_code = NEW.process_status_type_code) OR
    (OLD.process_status_type_code = 1 AND NEW.process_status_type_code = 2) OR
    (OLD.process_status_type_code = 2 AND NEW.process_status_type_code = 3) OR
    (OLD.process_status_type_code = 3 AND NEW.process_status_type_code = 2) OR
    (OLD.process_status_type_code IN (2, 3) AND NEW.process_status_type_code = 4)))
EXECUTE FUNCTION f_change_process_status();


CREATE OR REPLACE FUNCTION f_activate_process() RETURNS trigger AS $$
DECLARE
count bigint;
BEGIN
    count := (SELECT COUNT(*) FROM (SELECT Variant.next_step_id FROM Variant 
        INNER JOIN (Decision INNER JOIN (Step INNER JOIN Process 
                                        ON Step.process_id = Process.process_id) 
                    ON step_id = decision_id) 
        ON Variant.decision_id = Decision.decision_id
    WHERE Variant.next_step_id IS NULL) AS variant_with_no_next_step);
    IF count > 0 THEN
        RAISE EXCEPTION 'There are % variants at the Decision steps of this process 
        that have no next step assigned to them. Every variant must lead to the next 
        step.', count;
    END IF; 
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path=public, pg_temp;

COMMENT ON FUNCTION f_activate_process() IS 'This function ensures that only processes where every variant has an associated next step can be activated.';

CREATE TRIGGER trig_activate_process BEFORE UPDATE OF process_status_type_code ON Process
FOR EACH ROW WHEN (OLD.process_status_type_code <> NEW.process_status_type_code AND NEW.process_status_type_code = 2)
EXECUTE FUNCTION f_activate_process();



