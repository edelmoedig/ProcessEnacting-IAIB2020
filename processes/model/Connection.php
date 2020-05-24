<?php

class Connection
{

    private static $conn;

    public function connect()
    {

        $params = parse_ini_file('./config.ini');

        if (!$params) {
            throw new Exception("Database config cannot be read.");
        }

        $conStr = sprintf("pgsql:host=%s;port=%s;dbname=%s;user=%s;password=%s",
            $params['host'],
            $params['port'],
            $params['database'],
            $params['user'],
            $params['password']);

        $pdo = new PDO($conStr);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        return $pdo;
    }

    public static function get()
    {
        if (null === static::$conn) {
            static::$conn = new static();
        }

        return static::$conn;
    }

}
