<?php

$parallelActions = $process->getParallelActions($_GET['step']);

try {
    if (isset($_POST['edit-step-btn']) && !empty($_POST['step-description'])) {
        $process->changeStepDescription($step['step_id'], htmlspecialchars($_POST['step-description']));
        notifications\set('Successfully edited', 'Step has been successfully edited.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['edit-action-btn'])) {
        $id = $_POST['edit-action-btn'];
        if (!empty($_POST['action-description-' . $id])) {
            $process->changeStepDescription($id, htmlspecialchars($_POST['action-description-' . $id]));
            notifications\set('Successfully edited', 'Step has been successfully edited.', 'green');
        }
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['remove-action-btn'])) {
        $process->removeStep($_POST['remove-action-btn']);
        notifications\set('Action successfully removed', 'Step has been successfully edited.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['add-action-btn'])) {
        if (!empty($_POST['new-action-description'])) {
            $process->addActionInParallelActivity($_GET['pr'], $_GET['step'], htmlspecialchars($_POST['new-action-description']));
            notifications\set('Action successfully added', 'Step has been successfully edited.', 'green');
        }
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    }
} catch (PDOException $e) {
    notifications\set('Error', 'There has been an error.', 'red');
    echo "<meta http-equiv='refresh' content='0'>";
    exit();
}

echo "<div class='ui raised text container segment'>
        <h3>Parallel activity</h3>
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
        <h3>Parallel actions (must be more than 2)</h3>
        <form method='post' class='ui form'>
        <div class='inline fields'>
            <div class='fourteen wide field'>
                <textarea name ='new-action-description' placeholder='Parallel action description' autocomplete='off' required rows='3'></textarea>
            </div>
            <div class='two wide field'>
                <button name='add-action-btn' class='ui green button' type='submit'>Add</button>
            </div>
      </div></form>
    ";
if (empty($parallelActions)) {
    echo "<p>There are no associated parallel actions.</p>";
} else {
    foreach ($parallelActions as $pa) {
        echo "<form method='post' class='ui form'>
              <div class='inline fields'>
                    <div class='fourteen wide field'>
                        <textarea name ='action-description-{$pa['action_id']}' placeholder='Parallel action description' autocomplete='off' required rows='3'>{$pa['action_description']}</textarea>
                    </div>
                    <div class='one wide field'>
                        <button value='{$pa['action_id']}' name='edit-action-btn' class='ui icon green button' type='submit'><i class='pen square icon'></i></button>
                    </div>
                    <div class='one wide field'>
                        <button value='{$pa['action_id']}' name='remove-action-btn' class='ui icon red button' type='submit'><i class='trash icon'></i></button>
                    </div>
              </div>
              </form>
        ";
    }
}

echo "</form></div>";

