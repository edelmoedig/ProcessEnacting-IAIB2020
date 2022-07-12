<?php

if (isset($_GET["access"]) && isset($_SESSION['accessedProcesses']) && in_array($_GET["access"], $_SESSION['accessedProcesses'])) {
    $first_step = (new Process)->getProcess($_GET["access"])['first_step_id'];
    notifications\set('Access allowed', 'Access to this process has been granted.', 'green');
    echo "<script>window.location = 'enact.php?pr={$_GET['access']}&step={$first_step}'</script>";
    exit;
}

if (!empty($_POST["password"])) {
    try {
        $result = (new Process)->accessProcess($_GET["access"], $_POST["password"]);
        if ($result) {
            $first_step = (new Process)->getProcess($_GET["access"])['first_step_id'];
            $_SESSION['accessedProcesses'][] = $_GET["access"];
            notifications\set('Access allowed', 'Access to this process has been granted.', 'green');
            echo "<script>window.location = 'enact.php?pr={$_GET['access']}&step={$first_step}'</script>";
            exit;
        } else {
            $_SESSION['error'] = "Wrong password.";
        }
    } catch (PDOException $e) {
        notifications\set('Access denied', 'There has been an error while accessing this process.', 'red');
    }
}

echo "
    <div class=\"ui modal\">
        <i class=\"close icon\"></i>
        <div class=\"header\">
            Please enter the password to access this process
        </div>
        <div class=\"image content\">
            <div class=\"description\">
                <form id=\"processAccessForm\" class=\"ui form\" method=\"post\" action=\"#\">
                    <div class=\"ui fluid action input\">
                        <input type=\"password\" name=\"password\" placeholder=\"Password\">
                        <button class=\"ui button\" type=\"submit\">Enter</div>
                </form>
            </div>
        </div>
    </div>
";
