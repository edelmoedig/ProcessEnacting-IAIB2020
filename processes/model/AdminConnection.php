<?php

class AdminConnection
{

    private static $conn;

    public function connect()
    {

        $conStr = sprintf("pgsql:host=%s;port=%s;dbname=%s;user=%s;password=%s",
            'localhost',
            '5432',
            'processes',
            'process_administrator',
            'wasd1234');

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
