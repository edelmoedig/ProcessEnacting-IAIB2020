<?php

$steps = $process->getPossibleSteps($_GET['pr'], $_GET['step']);

if (isset($_POST['connect-step-btn']) && !empty($_GET['option'])) {
    $process->changeOptionNextStep($_POST['connect-step-btn'], $_GET['option']);
    header("Location: ../processes/edit_step.php?pr={$_GET['pr']}&option={$_GET['option']}&step={$_GET['step']}");
    echo "<meta http-equiv='refresh' content='0'>";
    exit();
}

?>


<div class='ui modal'>
    <i class='close icon'></i>
    <div class='header'>
        Connect to an existing step
    </div>
    <div class="scrolling content">
    <div class="ui relaxed divided list">
    <?php
    foreach ($steps as $s) {
        echo "
          <div class='item'>
            <form method='post'>
                <p>{$s['step_description']}</p><button value='{$s['step_id']}' name='connect-step-btn' class='ui green button' type='submit'>Choose</button>
            </form>
          </div>
        ";
    }
    ?>
    </div>
    </div>
</div>

