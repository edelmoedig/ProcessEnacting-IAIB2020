CREATE OR REPLACE FUNCTION f_register_process() RETURNS trigger AS $$
BEGIN
    NEW.process_status_type_code := 1,
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path=public, pg_temp;

COMMENT ON FUNCTION f_register_process() IS 'This function ensures that all processes are created with status "On hold" by setting the status code of newly created processes accordingly.'.;

CREATE TRIGGER trig_register_process BEFORE INSERT ON Process
FOR EACH ROW WHEN (NEW.process_status_type_code <> 1)
EXECUTE FUNCTION f_register_process();

CREATE OR REPLACE FUNCTION f_activate_process RETURNS trigger AS $$
BEGIN
    
