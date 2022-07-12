<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
require "functions/notifications.php";
session_start();

if (isset($_GET['search'])) {
    $processes = (new Process)->searchAllActiveProcessesByName($_GET['search']);
} else {
    $processes = (new Process)->getAllActiveProcesses();
}

unset($_SESSION['currentPr']);
unset($_SESSION['currentUsage']);
?>

<html lang="en">
<head>
    <title>Active processes</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="default.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.6/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>

<?php include "include/navigation.php"; ?>
<?php include "include/password_access.php"; ?>
<?php notifications\displayOnce(); ?>
<?php include "include/search.php"; ?>

<?php

foreach ($processes as $pr) {
    if ($pr['has_password']) {
        echo
            "<div class='ui raised very padded text container segment'>
                <h2 class='ui header'>{$pr['process_name']}</h2>
                <p>{$pr['process_description']}</p>
                    <a href='?access={$pr['process_id']}'>
                        <div class='ui yellow inverted clickable segment'>
                        <i class='angle right icon'></i>
                            <i class='lock icon'></i>ENTER WITH PASSWORD
                        </div>
                    </a>
                    <p><small><i class='address card outline icon'></i>{$pr['owner']}<i class='calendar alternate outline icon'></i>{$pr['reg_time']}</small></p>
            </div>";
    }
    else {
        echo
            "<div class='ui raised very padded text container segment'>
                <h2 class='ui header'>{$pr['process_name']}</h2>
                <p>{$pr['process_description']}</p>
                    <a href='enact.php?pr={$pr['process_id']}&step={$pr['first_step_id']}'>
                        <div class='ui green inverted clickable segment'>
                        <i class='angle right icon'></i>
                            ENTER
                        </div>
                    </a>
                    <p><small><i class='address card outline icon'></i>{$pr['owner']}<i class='calendar alternate outline icon'></i>{$pr['reg_time']}</small></p>
            </div>";
    }
}

if (isset($_GET['access'])) {
    echo "<script>
    $('.ui.modal').modal('show');
    </script>";
}

?>
</body>
</html>
