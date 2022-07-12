<?php
    require "functions/notifications.php";
    session_start();
    $_SESSION = array();
    session_destroy();
    notifications\set("Logged out", "You have successfully logged out.", "green");
    header("Location: index.php");
    exit;
