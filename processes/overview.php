<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
require "functions/notifications.php";
session_start();

if (!isset($_SESSION['id'])) {
    notifications\set('Access denied', 'Please log in.', 'red');
    header("Location: login.php");
    exit;
}

$process = new Process();

if (isset($_GET['search'])) {
    $processes = $process->searchAllProcessesByName($_GET['search']);
} else {
    $processes = $process->getAllProcesses();
}

$segmentColors = array('Active' => 'green', 'On hold' => 'grey', 'Inactive' => 'orange', 'Ended' => 'black');

unset($_SESSION['currentPr']);
unset($_SESSION['currentUsage']);
?>

<html lang="en">
<head>
    <title>Overview</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="default.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.6/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>

<?php include "include/navigation.php"; ?>
<?php include "include/search.php"; ?>
<?php include "include/form_create_process.php"; ?>
<?php notifications\displayOnce() ?>

<?php

foreach ($processes as $pr) {
        echo
            "<div class='ui raised text container segment'>
                <div class='ui {$segmentColors[$pr['current_status']]} floated inverted segment'>{$pr['current_status']}";
        if ($pr['has_password']) echo " | <i class='lock icon'></i>";
        echo
            "</div>
                <h2 class='ui header'>{$pr['process_name']}</h2>
                <p>{$pr['process_description']}</p>";
        if ($pr['current_status'] !== 'Ended') {
            echo "
                <a href='edit.php?pr={$pr['process_id']}'>
                    <div class='ui teal inverted clickable segment'>
                    <i class='pen square icon'></i>
                        EDIT
                    </div>
                </a>";
        }
        echo "
                <p><small><i class='address card outline icon'></i>{$pr['owner']}<i class='calendar alternate outline icon'></i>{$pr['reg_time']}</small></p>
            </div>";
}

?>

</body>
</html>
