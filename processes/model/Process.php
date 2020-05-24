<?php

require "Connection.php";

class Process {

    private $conn;

    public function __construct()
    {
        $this->conn = Connection::get()->connect();
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
        $stmt->execute([strtolower('%'.$filter.'%')]);
        $processes = $stmt->fetchAll();
        return $processes;
    }

    public function getProcess($id)
    {
        $stmt = $this->conn->prepare("SELECT * FROM processes.active_processes WHERE process_id=?");
        $stmt->execute([$id]);
        $process = $stmt->fetch();
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
        $stmt = $this->conn->prepare("SELECT * FROM processes.parallel_actions WHERE parallel_activity_id=? ORDER BY action_id");
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
        $stmt = $this->conn->prepare("SELECT * FROM processes.decision_tables WHERE associated_step_id=? AND is_active = true");
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
}
