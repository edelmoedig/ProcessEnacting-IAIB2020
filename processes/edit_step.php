<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
require "functions/notifications.php";
session_start();

if (!isset($_SESSION['id'])) {
    notifications\set('Access error', 'Please log in.', 'red');
    echo "<script>window.location = 'login.php'</script>";
    exit;
}

$process = new Process();
if (!isset($_GET['step'])) {
    notifications\set('Access error', 'There is no such process.', 'red');
    echo "<script>window.location = 'overview.php'</script>";
    exit;
}
$step = $process->getStep($_GET['step']);
if (empty($step)) {
    notifications\set('Access error', 'There is no such process.', 'red');
    echo "<script>window.location = 'overview.php'</script>";
    exit;
}
$pr = $process->getProcess($step['process_id']);

if (!in_array($pr['current_status'], ['On hold', 'Inactive'])) {
    notifications\set('Access error', "This process can not currently be edited as its current status is '{$pr['current_status']}'.", 'red');
    echo "<script>window.location = 'edit.php?pr={$_GET['pr']}'</script>";
    }

if (isset($_GET['prev'])) {
    $prev = $process->getStep($_GET['prev']);
    if (empty($prev)) {
        notifications\set('Access error', 'There has been an error.', 'red');
        echo "<script>window.location = 'edit.php?pr={$_GET['pr']}'</script>";
        exit;
    }
}
?>

<html lang="en">
<head>
    <title>Edit step</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="default.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.6/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>

<?php include "include/navigation.php"; ?>
<?php notifications\displayOnce(); ?>

<?php

if ($step['is_decision']) {
    include 'include/form_edit_decision.php';
} else if ($step['is_parallel_activity']) {
    include 'include/form_edit_parallel_activity.php';
} else {
    include 'include/form_edit_action.php';
}

include 'include/form_step_links.php';
