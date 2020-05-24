<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
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
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
<?php include "navigation.php"; ?>
<?php include "search.php"; ?>

<?php
if (isset($_SESSION['error'])) {
    echo "<div class=\"ui center aligned three column grid\">
            <div class=\"ui negative message\">
                <div class=\"header\">
                     Error
                </div>
    ";
    echo "<p>" . $_SESSION['error'] . "</p></div></div>";
    unset($_SESSION['error']);
}
if (isset($_SESSION['success'])) {
    echo "<div class=\"ui center aligned three column grid\">
            <div class=\"ui positive message\">
                <div class=\"header\">
                    Login success
                </div>
            </div>
    ";
    echo "<p>" . $_SESSION['success'] . "</p></div></div>";
    unset($_SESSION['success']);
}
?>

<?php

foreach ($processes as $pr) {
    echo
        "<div class='ui raised very padded text container segment'>
            <h2 class='ui header'>{$pr['process_name']}</h2>
            <p>{$pr['process_description']}</p>
                <a href='enact.php?pr={$pr['process_id']}&step={$pr['first_step_id']}'>
                    <div class='ui green inverted segment'>
                    <i class=\"angle right icon\"></i>
                        ENTER
                    </div>
                </a>
                <br>
                <p><small><i class=\"address card outline icon\"></i>{$pr['owner']}<i class=\"calendar alternate outline icon\"></i>{$pr['reg_time']}</small></p>
        </div>";
}

?>
</body>
</html>
