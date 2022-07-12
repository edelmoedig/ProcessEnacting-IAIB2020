<?php

require "RegularConnection.php";
require "AdminConnection.php";

class Process
{

    private $conn;
    private $adminConn;

    public function __construct()
    {
        $this->conn = RegularConnection::get()->connect();
        $this->adminConn = AdminConnection::get()->connect();
    }

    public function getAllActiveProcesses()
    {
        $stmt = $this->conn->query("SELECT * FROM processes.active_processes ORDER BY process_name");
        $processes = $stmt->fetchAll();
        return $processes;
    }

    public function searchAllActiveProcessesByName($filter)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.active_processes WHERE lower(process_name) LIKE ? ORDER BY process_name");
        $stmt->execute([strtolower('%' . $filter . '%')]);
        $processes = $stmt->fetchAll();
        return $processes;
    }

    public function getAllProcesses()
    {
        $stmt = $this->conn->query("SELECT * FROM processes.all_processes ORDER BY reg_time DESC");
        $processes = $stmt->fetchAll();
        return $processes;
    }

    public function searchAllProcessesByName($filter)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.all_processes WHERE lower(process_name) LIKE ? ORDER BY process_name");
        $stmt->execute([strtolower('%' . $filter . '%')]);
        $processes = $stmt->fetchAll();
        return $processes;
    }

    public function getProcess($id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.all_processes WHERE process_id=?");
        $stmt->execute([$id]);
        $process = $stmt->fetch();
        return $process;
    }

    public function getPossibleSteps($process_id, $except_step_id) {
        $stmt = $this->conn->prepare("SELECT * FROM processes.process_steps LEFT JOIN processes.parallel_actions ON step_id = action_id WHERE action_id IS NULL AND process_id = ? AND step_id <> ? AND next_step_id <> ?");
        $stmt->execute([$process_id, $except_step_id, $except_step_id]);
        $process = $stmt->fetchAll();
        return $process;
    }

    public function getStep($step_id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.process_steps WHERE step_id=?");
        $stmt->execute([$step_id]);
        $step = $stmt->fetch();
        return $step;
    }

    public function getDecisionOptions($step_id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.decision_options WHERE decision_id=?");
        $stmt->execute([$step_id]);
        $options = $stmt->fetchAll();
        return $options;
    }

    public function getParallelActions($step_id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.parallel_actions WHERE parallel_activity_id=? ORDER BY action_id DESC");
        $stmt->execute([$step_id]);
        $parallels = $stmt->fetchAll();
        return $parallels;
    }

    public function getProcessLinks($id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.process_links WHERE process_id=? ORDER BY priority_nr");
        $stmt->execute([$id]);
        $links = $stmt->fetchAll();
        return $links;
    }

    public function getStepLinks($step_id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.step_links WHERE step_id=? ORDER BY priority_nr");
        $stmt->execute([$step_id]);
        $links = $stmt->fetchAll();
        return $links;
    }

    public function getDecisionTables($step_id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.decision_tables WHERE associated_step_id=? AND is_active = TRUE");
        $stmt->execute([$step_id]);
        $links = $stmt->fetchAll();
        return $links;
    }

    public function getDecisionTableEntries($table_id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.decision_table_entries WHERE decision_table_id=? ORDER BY seq_nr");
        $stmt->execute([$table_id]);
        $links = $stmt->fetchAll();
        return $links;
    }

    public function logProcessUsage($process_id)
    {
        $stmt = $this->conn->prepare("SELECT processes.f_log_process_usage(?)");
        $stmt->execute([$process_id]);
        $processUsage = $stmt->fetch();
        return $processUsage;
    }

    public function logStepClick($process_usage_id, $step_id)
    {
        $stmt = $this->conn->prepare("SELECT processes.f_log_step_click(?, ?)");
        $stmt->execute([$process_usage_id, $step_id]);
        $stepClick = $stmt->fetch();
        return $stepClick;
    }

    public function accessProcess($process_id, $process_password)
    {
        $stmt = $this->conn->prepare("SELECT processes.f_access_process_with_password(?, ?)");
        $stmt->execute([$process_id, $process_password]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function createProcess($name, $description, $owner, $password)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_register_process(?, ?, ?, ?)");
        $stmt->execute([$name, $description, $owner, $password]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeProcessNameAndDescription($process_id, $name, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_process_name_and_description(?, ?, ?)");
        $stmt->execute([$process_id, $name, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeProcessPassword($process_id, $password)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_process_password(?, ?)");
        $stmt->execute([$process_id, $password]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function activateProcess($process_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_activate_process(?)");
        $stmt->execute([$process_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function deactivateProcess($process_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_deactivate_process(?)");
        $stmt->execute([$process_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function endProcess($process_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_end_process(?)");
        $stmt->execute([$process_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function deleteProcess($process_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_forget_process(?)");
        $stmt->execute([$process_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addFirstAction($process_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_first_action(?, ?)");
        $stmt->execute([$process_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addActionToStep($process_id, $previous_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_action_to_step(?, ?, ?)");
        $stmt->execute([$process_id, $previous_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addActionToStepExistingNext($process_id, $previous_step_id, $next_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_action_to_step_existing_next(?, ?, ?, ?)");
        $stmt->execute([$process_id, $previous_step_id, $next_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addActionToOption($process_id, $option_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_action_to_option(?, ?, ?)");
        $stmt->execute([$process_id, $option_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addActionToOptionExistingNext($process_id, $option_id, $next_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_action_to_option_existing_next(?, ?, ?, ?)");
        $stmt->execute([$process_id, $option_id, $next_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addFirstParallelActivity($process_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_first_parallel_activity(?, ?)");
        $stmt->execute([$process_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addParallelActivityToStep($process_id, $previous_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_parallel_activity_to_step(?, ?, ?)");
        $stmt->execute([$process_id, $previous_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addParallelActivityToStepExistingNext($process_id, $previous_step_id, $next_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_parallel_activity_to_step_existing_next(?, ?, ?, ?)");
        $stmt->execute([$process_id, $previous_step_id, $next_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addParallelActivityToOption($process_id, $option_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_parallel_activity_to_option(?, ?, ?)");
        $stmt->execute([$process_id, $option_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addParallelActivityToOptionExistingNext($process_id, $option_id, $next_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_parallel_activity_to_option_existing_next(?, ?, ?, ?)");
        $stmt->execute([$process_id, $option_id, $next_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addActionInParallelActivity($process_id, $parallel_activity_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_action_in_parallel_activity(?, ?, ?)");
        $stmt->execute([$process_id, $parallel_activity_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addFirstDecision($process_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_first_decision(?, ?)");
        $stmt->execute([$process_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addDecisionToStep($process_id, $previous_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_decision_to_step(?, ?, ?)");
        $stmt->execute([$process_id, $previous_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addDecisionToStepExistingNext($process_id, $previous_step_id, $next_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_decision_to_step_existing_next(?, ?, ?, ?)");
        $stmt->execute([$process_id, $previous_step_id, $next_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addDecisionToOption($process_id, $option_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_decision_to_option(?, ?, ?)");
        $stmt->execute([$process_id, $option_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addDecisionToOptionExistingNext($process_id, $option_id, $next_step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_decision_to_option_existing_next(?, ?, ?, ?)");
        $stmt->execute([$process_id, $option_id, $next_step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addOptionToDecision($decision_id, $guard, $weight)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_option_to_decision(?, ?, ?)");
        $stmt->execute([$decision_id, $weight, $guard]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addOptionToDecisionExistingNext($decision_id, $next_step_id, $weight, $guard)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_option_to_decision_existing_next(?, ?, ?, ?)");
        $stmt->execute([$decision_id, $next_step_id, $weight, $guard]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function removeOptionFromDecision($option_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_remove_option_from_decision(?)");
        $stmt->execute([$option_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeOptionGuardAndWeight($option_id, $guard, $weight)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_option_weight_and_guard(?, ?, ?)");
        $stmt->execute([$option_id, $guard, $weight]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeStepDescription($step_id, $description)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_step_description(?, ?)");
        $stmt->execute([$step_id, $description]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function removeStep($step_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_remove_step(?)");
        $stmt->execute([$step_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeStepNextStep($step_id, $next_step_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_step_next_step(?, ?)");
        $stmt->execute([$step_id, $next_step_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeOptionNextStep($option_id, $next_step_id)
    {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_option_next_step(?, ?)");
        $stmt->execute([$option_id, $next_step_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addProcessLink($process_id, $url, $name, $priority) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_process_link(?, ?, ?, ?)");
        $stmt->execute([$process_id, $url, $name, $priority]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function removeProcessLink($process_link_id) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_remove_process_link(?)");
        $stmt->execute([$process_link_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function editProcessLink($process_link_id, $url, $name, $priority) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_edit_process_link(?, ?, ?, ?)");
        $stmt->execute([$process_link_id, $url, $name, $priority]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addStepLink($step_id, $url, $name, $priority) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_add_step_link(?, ?, ?, ?)");
        $stmt->execute([$step_id, $url, $name, $priority]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function removeStepLink($step_link_id) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_remove_step_link(?)");
        $stmt->execute([$step_link_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function editStepLink($step_link_id, $url, $name, $priority) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_edit_step_link(?, ?, ?, ?)");
        $stmt->execute([$step_link_id, $url, $name, $priority]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addDecisionTable($action_id, $name) {
        $stmt = $this->conn->prepare("SELECT processes.f_add_decision_table(?, ?)");
        $stmt->execute([$action_id, $name]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function switchDecisionTableActivation($decision_table_id) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_switch_activation_decision_table(?)");
        $stmt->execute([$decision_table_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function removeDecisionTableActivation($decision_table_id) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_remove_decision_table(?)");
        $stmt->execute([$decision_table_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeDecisionTableName($decision_table_id, $name) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_decision_table_name(?)");
        $stmt->execute([$decision_table_id, $name]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function addDecisionTableEntry($decision_table_id, $condition, $action, $seq_nr) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_decision_table_name(?, ?, ?, ?)");
        $stmt->execute([$decision_table_id, $condition, $action, $seq_nr]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function removeDecisionTableEntry($decision_table_entry_id) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_remove_decision_table_entry(?)");
        $stmt->execute([$decision_table_entry_id]);
        $result = $stmt->fetchColumn();
        return $result;
    }

    public function changeDecisionTableEntry($decision_table_entry_id, $condition, $action, $seq_nr) {
        $stmt = $this->adminConn->prepare("SELECT processes.f_change_decision_table_entry(?, ?, ?, ?)");
        $stmt->execute([$decision_table_entry_id, $condition, $action, $seq_nr]);
        $result = $stmt->fetchColumn();
        return $result;
    }

}
