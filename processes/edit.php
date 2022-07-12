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
$pr = $process->getProcess($_GET['pr']);
if (empty($pr)) {
    notifications\set('Access error', 'There is no such process.', 'red');
    header("Location: overview.php");
    exit;
}
?>

<html lang="en">
<head>
    <title>Edit</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="default.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.6/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>

<?php include "include/navigation.php"; ?>
<?php notifications\displayOnce(); ?>

<?php include 'include/form_edit_process_name_desc.php'; ?>
<?php include 'include/form_change_process_status.php'; ?>
<?php include 'include/form_change_process_password.php'; ?>
<?php include 'include/form_first_step.php'; ?>
<?php include 'include/form_process_links.php'; ?>

</body>
</html>
