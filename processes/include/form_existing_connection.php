<?php

$steps = $process->getPossibleSteps($_GET['pr'], $_GET['step']);

if (isset($_POST['connect-step-btn']) && !empty($_GET['option'])) {
    $process->changeOptionNextStep($_GET['option'], $_POST['connect-step-btn']);
    header("Location: ../processes/edit_step.php?pr={$_GET['pr']}&option={$_GET['option']}&step={$_GET['step']}");
    exit();
} else if (isset($_POST['connect-step-btn']) && !empty($_GET['step'])) {
    $process->changeStepNextStep($_GET['step'], $_POST['connect-step-btn']);
    header("Location: ../processes/edit_step.php?pr={$_GET['pr']}&step={$_GET['step']}&prev={$_POST['connect-step-btn']}");
    exit();
}

?>

<div class='ui raised text container segment'>
    <div class='header'>
        <h3>Connect to an existing step<h3>
    </div>
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

<?php
