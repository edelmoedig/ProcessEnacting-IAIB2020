<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Process.php";
require "functions/notifications.php";
session_start();

$process = new Process();
$step = $process->getStep($_GET['step']);
$pr = $process->getProcess($step['process_id']);

if ($_GET['pr'] != $step['process_id'] or empty($pr)) {
    notifications\set('Access error', 'There is no such process.', 'red');
    header("Location: index.php");
    exit;
}

if ($pr['has_password'] && !in_array($pr['process_id'], $_SESSION['accessedProcesses'])) {
    notifications\set('Access denied', 'Please enter the password to access this process.', 'red');
    header("Location: index.php?access={$pr['process_id']}");
    exit;
}

if (empty($_SESSION['currentPr']) or empty($_SESSION['currentUsage']) or $_SESSION['currentPr'] != $_GET['pr']) {
    $_SESSION['currentPr'] = $_GET['pr'];
    $processUsage = $process->logProcessUsage($_SESSION['currentPr'])[0];
    $_SESSION['currentUsage'] = $processUsage;
    $process->logStepClick($_SESSION['currentUsage'], $_GET['step']);
} else {
    $process->logStepClick($_SESSION['currentUsage'], $_GET['step']);
}

$decisionOptions = array();
$parallelActions = array();

if ($step['is_decision']) {
    $decisionOptions = $process->getDecisionOptions($_GET['step']);
} else if ($step['is_parallel_activity']) {
    $parallelActions = $process->getParallelActions($_GET['step']);
}
$processLinks = $process->getProcessLinks($_GET['pr']);
$stepLinks = $process->getStepLinks($_GET['step']);

$typeName = "";
if (!empty($decisionOptions)) {
    $typeName = "Decision";
} else if (!empty($parallelActions)) {
    $typeName = "Parallel activity";
} else {
    $typeName = "Action";
}

$decisionTables = $process->getDecisionTables($_GET['step']);

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
<?php notifications\displayOnce(); ?>

<div class="ui grid container">
    <div class="two wide column">
        <?="<i class='angle double left icon'></i><h3><span title='Go back to the first step'><a href='enact.php?pr={$pr['process_id']}&step={$pr['first_step_id']}'>{$pr['process_name']}</span></h3></a>"?>
    </div>
    <div class="eleven wide column">
        <?php echo "<h3>$typeName</h3>" ?>
        <?php echo $step['step_description'] ?>
        <div class="ui segments">
            <?php
            $i = 0;
            foreach ($parallelActions as $pA) {
                $i++;
                echo "<div class='ui segment'>
                            <p>{$i}. {$pA['action_description']}</p>
                      </div>";
            }
            ?>
        </div>
        <?php
            foreach ($decisionTables as $dT) {
                echo "<h4>{$dT['decision_table_name']}</h4>";
                $decisionTableEntries = $process->getDecisionTableEntries($dT['decision_table_id']);
                echo "<table class='ui celled table'><tbody>";
                foreach ($decisionTableEntries as $dTE) {
                    echo "
                            <tr>
                              <td>{$dTE['condition']}</td>
                              <td>{$dTE['action']}</td>
                            </tr>

                    ";
                }
                echo "</tbody></table>";
            }
        ?>
        <?php
        if ($decisionOptions) {
            foreach ($decisionOptions as $o) {
                echo "
                <a href='enact.php?pr={$step['process_id']}&step={$o['next_step_id']}'>
                    <div class='ui green segment'><i class='angle right icon'></i>{$o['guard']}<span style='float:right;'>{$o['weight']}</span></div>
                </a>
                ";
            }
        } else if ($step['next_step_id']) {
            echo "
                <a href='enact.php?pr={$step['process_id']}&step={$step['next_step_id']}'>
                    <div class='ui green inverted segment'><i class='angle right icon'></i>NEXT</div>
                </a>
                ";
        } else {
            echo "
                <a href='index.php'>
                    <div class='ui green inverted segment'><i class='check icon'></i>THE PROCESS IS OVER</div>
                </a>
                ";
        }
        ?>
    </div>
    <div class="link-list three wide column">
        <h3>Process links</h3>
        <div class="ui relaxed divided list">
            <?php
            if (empty($processLinks)) {
                echo "<p>There are no associated process links.</p>";
            } else foreach ($processLinks as $prL) {
                echo "
                        <div class='item'>
                            <div class='content'>
                                <div class='description'>{$prL['process_link_name']}</div>
                                <a class='header' href='{$prL['process_link_url']}' target='_blank'>{$prL['process_link_url']}</a>
                            </div>
                        </div>
                    ";
            }
            ?>
        </div>
        <h3>Step links</h3>
        <div class="ui relaxed divided list">
        <?php
        $noStepLinks = true;
        foreach ($stepLinks as $stL) {
            $noStepLinks = false;
            echo "
                        <div class='item'>
                            <div class='content'>
                                <div class='description'>{$stL['step_link_name']}</div>
                                <a class='header' href='{$stL['step_link_url']}' target='_blank'>{$stL['step_link_url']}</a>
                            </div>
                        </div>
                    ";
        }
        $i = 0;
        foreach ($parallelActions as $pA) {
            $i++;
            $parallelStepLinks = $process->getStepLinks($pA['action_id']);
            if (!empty($parallelStepLinks)) {
                $shortDesc = strlen($pA['action_description']) > 50 ? substr($pA['action_description'],0,50)."..." : $pA['action_description'];
                echo "<h4>{$i}. {$shortDesc}</h4>";
            }
            foreach ($parallelStepLinks as $pSL) {
                $noStepLinks = false;
                echo "
                            <div class='item'>
                                <div class='content'>
                                    <div class='description'>{$pSL['step_link_name']}</div>
                                    <a class='header' href='{$pSL['step_link_url']}' target='_blank'>{$pSL['step_link_url']}</a>
                                </div>
                            </div>
                        ";
                }
            }
        if ($noStepLinks) {
            echo "<p>There are no associated step links.</p>";
        }
        ?>
        </div>
    </div>
</div>

</body>
</html>
