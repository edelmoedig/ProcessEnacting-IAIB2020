<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
session_start();

if (!isset($_SESSION['id'])) {
    header("Location: login.php");
    exit;
}

$process = new Process();
$pr = $process->getProcess($_GET['pr']);

?>

<html lang="en">
<head>
    <title>Edit</title>
    <link rel="stylesheet" type="text/css" href="default.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>
<?php include "navigation.php"; ?>

<?php include 'form_edit_process_name_desc.php'; ?>
<?php include 'form_change_process_status.php'; ?>
<?php include 'form_change_process_password.php'; ?>
<?php include 'form_process_links.php'; ?>

</body>
</html>
