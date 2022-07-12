<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
require "functions/notifications.php";
session_start();

if (!isset($_SESSION['id'])) {
    header("Location: login.php");
    exit;
}

$process = new Process();
$pr = $process->getProcess($_GET['pr']);
if (empty($pr)) {
    notifications\set('Access error', 'There is no such process.', 'red');
    echo "<script>window.location = 'overview.php'</script>";
    exit;
}

if (!in_array($pr['current_status'], ['On hold', 'Inactive'])) {
    notifications\set('Access error', "This process can not currently be edited as its current status is '{$pr['current_status']}'.", 'red');
    echo "<script>window.location = 'edit.php?pr={$_GET['pr']}'</script>";
    exit;
}

$validTypes = array('action', 'decision', 'parallel');
if (($pr['first_step_id'] != null && !isset($_GET['prev']) || !in_array($_GET['type'], $validTypes))) {
    notifications\set('Access error', 'There has been an error.', 'red');
    echo "<script>window.location = 'edit.php?pr={$_GET['pr']}'</script>";
    exit;
}
if (isset($_GET['prev'])) {
    $prev = $process->getStep($_GET['prev']);
    if (empty($prev) || ($prev['process_id'] != $_GET['pr'])) {
        notifications\set('Access error', 'There has been an error.', 'red');
        echo "<script>window.location = 'edit.php?pr={$_GET['pr']}'</script>";
        exit;
    }
}
try {
    if (!empty($_GET['option'])) {
        if (isset($_POST['add-action-btn'])) {
            $step = $process->addActionToOption($_GET['pr'], $_GET['option'], htmlspecialchars($_POST['step-description']));
        } else if (isset($_POST['add-decision-btn'])) {
            $step = $process->addDecisionToOption($_GET['pr'], $_GET['option'], htmlspecialchars($_POST['step-description']));
        } else if (isset($_POST['add-parallel-btn'])) {
            $step = $process->addParallelActivityToOption($_GET['pr'], $_GET['option'], htmlspecialchars($_POST['step-description']));
        }
        notifications\set('Successfully edited', 'Next step successfully added.', 'green');
        echo "<script>window.location = 'edit_step.php?pr={$_GET['pr']}&step={$step}&prev={$_GET['prev']}}'</script>";
        exit();
    } else if (empty($_GET['prev'])) {
        if (isset($_POST['add-action-btn'])) {
            $step = $process->addFirstAction($_GET['pr'], htmlspecialchars($_POST['step-description']));
        } else if (isset($_POST['add-decision-btn'])) {
            $step = $process->addFirstDecision($_GET['pr'], htmlspecialchars($_POST['step-description']));
        } else if (isset($_POST['add-parallel-btn'])) {
            $step = $process->addFirstParallelActivity($_GET['pr'], htmlspecialchars($_POST['step-description']));
        }
        notifications\set('Successfully edited', 'First step successfully added.', 'green');
        echo "<script>window.location = 'edit_step.php?pr={$_GET['pr']}&step={$step}'</script>";
        exit;
    } else if (!empty($_GET['prev'])) {
        if (isset($_POST['add-action-btn'])) {
            $step = $process->addActionToStep($_GET['pr'], $_GET['prev'], htmlspecialchars($_POST['step-description']));
        } else if (isset($_POST['add-decision-btn'])) {
            $step = $process->addDecisionToStep($_GET['pr'], $_GET['prev'], htmlspecialchars($_POST['step-description']));
        } else if (isset($_POST['add-parallel-btn'])) {
            $step = $process->addParallelActivityToStep($_GET['pr'], $_GET['prev'], htmlspecialchars($_POST['step-description']));
        }
        notifications\set('Successfully edited', 'Next step successfully added.', 'green');
        echo "<script>window.location = 'edit_step.php?pr={$_GET['pr']}&step={$step}&prev={$_GET['prev']}'</script>";
        exit;
    }
} catch (PDOException $e) {
    notifications\set('Edit error', 'There has been an error while editing this process.', 'red');
    echo "<meta http-equiv='refresh' content='0'>";
    exit;
}

?>

<html lang="en">
<head>
    <title>Add step</title>
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

echo "<div class='ui raised text container segment'>
            <h3>New {$_GET['type']} step</h3><form method='post' class='ui form'>
            <div class='required field'>
                <label>Description</label>
                <textarea name ='step-description' placeholder='Step description' autocomplete='off' required></textarea>
            </div>
            <div class='field'>
                <button name='add-{$_GET['type']}-btn' class='ui green button' type='submit'>Add</button>
            </div>
      </div>
    ";
