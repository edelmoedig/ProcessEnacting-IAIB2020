<?php

$decisionOptions = $process->getDecisionOptions($_GET['step']);

try {
    if (isset($_POST['edit-step-btn']) && !empty($_POST['step-description'])) {
        $process->changeStepDescription($step['step_id'], htmlspecialchars($_POST['step-description']));
        notifications\set('Successfully edited', 'Step has been successfully edited.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['edit-option-btn'])) {
        $id = $_POST['edit-option-btn'];
        if (!empty($_POST['option-weight-' . $id])) {
            $process->changeOptionGuardAndWeight($id, htmlspecialchars($_POST['option-guard-' . $id]), $_POST['option-weight-' . $id]);
        } else {
            $process->changeOptionGuardAndWeight($id, htmlspecialchars($_POST['option-guard-' . $id]), null);
        }
        notifications\set('Successfully edited', 'Option has been successfully edited.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['remove-option-btn'])) {
        $process->removeOptionFromDecision($_POST['remove-option-btn']);
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['add-option-btn'])) {
        if (!empty($_POST['new-option-weight'])) {
            $process->addOptionToDecision($_GET['step'], htmlspecialchars($_POST['new-option-guard']), $_POST['new-option-weight']);
        } else {
            $process->addOptionToDecision($_GET['step'], htmlspecialchars($_POST['new-option-guard']), null);
        }
        notifications\set('Successfully added', 'Option has been successfully added.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit($_POST['add-option-btn']);
    } else if (isset($_POST['add-next-action-btn'])) {
        echo "<script>window.location = '../processes/add_step.php?pr={$_GET['pr']}&option={$_POST['add-next-action-btn']}&prev={$_GET['step']}&type=action'</script>";
        exit();
    } else if (isset($_POST['add-next-decision-btn'])) {
        echo "<script>window.location = './processes/add_step.php?pr={$_GET['pr']}&option={$_POST['add-next-decision-btn']}&prev={$_GET['step']}&type=decision'</script>";
        exit();
    } else if (isset($_POST['add-next-parallel-btn'])) {
        echo "<script>window.location = '../processes/add_step.php?pr={$_GET['pr']}&option={$_POST['add-next-parallel-btn']}&prev={$_GET['step']}&type=parallel'</script>";
        exit();
    } else if (isset($_POST['connect-existing-btn'])) {
        echo "<script>window.location = '../processes/connect_step.php?pr={$_GET['pr']}&option={$_POST['connect-existing-btn']}&step={$_GET['step']}&connect=true</script>";
        exit();
    }
} catch (PDOException $e) {
    notifications\set('Error', 'There has been an error.', 'red');
    echo "<meta http-equiv='refresh' content='0'>";
    exit();
}

echo "<div class='ui raised text container segment'>
        <h3>Decision step</h3>
        <form method='post' class='ui form'>
            <div class='required field'>
                <label>Description</label>
                <textarea name ='step-description' placeholder='Step description' autocomplete='off' required>{$step['step_description']}</textarea>
            </div>
            <div class='field'>
                <button name='edit-step-btn' class='ui green button' type='submit'>Edit</button>
            </div>
        </form>
    </div>
    ";

include 'step_buttons.php';

echo "<div class='ui raised text container segment'>
        <h3>Decision options (must be more than 2)</h3>
        <form method='post' class='ui form'>
        <div class='inline fields'>
            <div class='eleven wide field'>
                <textarea name ='new-option-guard' placeholder='Guard' autocomplete='off' required rows='1'></textarea>
            </div>
            <div class='two wide field'>
                <input title='Optional weight' type='number' step='0.1' name='new-option-weight' placeholder='Weight (optional)'>
            </div>
            <div class='three wide field'>
                <button name='add-option-btn' class='ui green button' type='submit'>Add</button>
            </div>
      </div></form>
    ";
if (empty($decisionOptions)) {
    echo "<p>There are no associated decision options.</p>";
} else {
    foreach ($decisionOptions as $o) {
        echo "<form method='post' class='ui form'>
              <div class='inline fields'>
                    <div class='ten wide field'>
                        <textarea name ='option-guard-{$o['option_id']}' placeholder='Guard' autocomplete='off' required rows='1'>{$o['guard']}</textarea>
                    </div>
                    <div class='two wide field'>
                        <input type='number' name='option-weight-{$o['option_id']}' placeholder='Weight' value='{$o['weight']}'>
                    </div>
                    <div class='one wide field'>
                        <button value='{$o['option_id']}' name='edit-option-btn' class='ui icon green button' type='submit'><i class='pen square icon' title='Edit'></i></button>
                    </div>";
        if (!$o['next_step_id']) {
            echo "<div class='one wide field'>
                        <button value='{$o['option_id']}' name='add-next-action-btn' class='ui green button' type='submit' title='Add next action'>A</button>
                    </div>
                    <div class='one wide field'>
                        <button value='{$o['option_id']}' name='add-next-decision-btn' class='ui green button' type='submit' title='Add next decision'>D</button>
                    </div>
                    <div class='one wide field'>
                        <button value='{$o['option_id']}' name='add-next-parallel-btn' class='ui green button' type='submit' title='Add next parallel activity'>P</button>
                    </div>
                    <div class='one wide field'>
                        <button value='{$o['option_id']}' name='connect-existing-btn' class='ui icon green button' type='submit' title='Connect existing step'><i class='plus icon'></i></button>
                    </div>
                    <div class='one wide field'>
                        <button value='{$o['option_id']}' name='remove-option-btn' class='ui icon red button' type='submit'><i class='trash icon' title='Remove'></i></button>
                 </div></div></form>";
        } else {
            echo "</form><div class='one wide field'>
                        <a href='edit_step.php?pr={$_GET['pr']}&step={$o['next_step_id']}&prev={$_GET['step']}'><div class='ui icon teal button' title='Next step'><i class='angle right icon'></i></div></a>
                 </div></div>";
        }
    }
}

echo "</div>";
