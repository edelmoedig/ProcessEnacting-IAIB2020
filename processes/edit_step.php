<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
session_start();

if (!isset($_SESSION['id'])) {
    header("Location: login.php");
    exit;
}

$process = new Process();
if (!isset($_GET['step'])) {
    header("Location: overview.php");
    exit;
}
$step = $process->getStep($_GET['step']);
if (empty($step)) {
    $_SESSION['error'] = "There is no such process.";
    header("Location: overview.php");
    exit;
}
$pr = $process->getProcess($step['process_id']);

if ($pr['current_status'] != "On hold" || $pr['current_status'] != "Inactive") {
    header("Location: edit.php?pr={$_GET['pr']}");
}

if (isset($_GET['prev'])) {
    $prev = $process->getStep($_GET['prev']);
    if (empty($prev)) {
        header("Location: edit.php?pr={$_GET['pr']}");
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
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>

<?php include "include/navigation.php"; ?>

<?php

if ($step['is_decision']) {
    include 'include/form_edit_decision.php';
} else if ($step['is_parallel_activity']) {
    include 'include/form_edit_parallel_activity.php';
} else {
    include 'include/form_edit_action.php';
}

include 'include/form_step_links.php';
