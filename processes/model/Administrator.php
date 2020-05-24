<?php

require "Connection.php";

class Administrator
{

    private $conn;

    public function __construct()
    {
        $this->conn = Connection::get()->connect();
    }

    public function register($email, $password, $given_name, $surname)
    {
        $stmt = $this->conn->prepare("SELECT processes.f_register_administrator(?, ?, ?, ?)");
        return $stmt->execute([$email, $password, $given_name, $surname]);
    }

    public function login($email, $password)
    {
        $stmt = $this->conn->prepare("SELECT processes.f_get_administrator_id(?, ?)");
        $stmt->execute([$email, $password]);
        return $stmt->fetch()[0];
    }
}
