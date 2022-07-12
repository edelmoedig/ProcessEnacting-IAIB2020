<?php

$stepLinks = $process->getStepLinks($_GET['step']);

try {
    if (isset($_POST['edit-link-btn'])) {
        $id = $_POST['edit-link-btn'];
        $process->editStepLink($id, htmlspecialchars($_POST['link-url-' . $id]), htmlspecialchars($_POST['link-name-' . $id]), $_POST['link-priority-' . $id]);
        notifications\set('Successfully edited', 'Status successfully changed.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['remove-link-btn'])) {
        $process->removeStepLink($_POST['remove-link-btn']);
        notifications\set('Successfully edited', 'Status successfully changed.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['add-link-btn'])) {
        $process->addStepLink($_GET['step'], htmlspecialchars($_POST['new-link-url']), htmlspecialchars($_POST['new-link-name']), $_POST['new-link-priority']);
        notifications\set('Successfully edited', 'Status successfully changed.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    }
} catch (PDOException $e) {
    notifications\set('Error', 'There has been an error.', 'red');
    echo "<meta http-equiv='refresh' content='0'>";
    exit();
}

echo "<div class='ui raised text container segment'>
        <h3>Step links</h3>
        <form method='post' class='ui form'>
            <div class='inline fields'>
                <div class='six wide field'>
                    <input type='text' name='new-link-url' placeholder='URL (unique)' required>
                </div>
                <div class='six wide field'>
                    <input type='text' name='new-link-name' placeholder='Name' required>
                </div>
                <div class='three wide field'>
                    <input type='number' name='new-link-priority' placeholder='Priority (unique)' required>
                </div>
                <div class='field'>
                    <button name='add-link-btn' class='ui green button' type='submit'>Add</button>
                </div>
            </div>
            </form>
    ";
if (empty($stepLinks)) {
    echo "<p>There are no associated step links.</p>";
} else {
    foreach ($stepLinks as $stL) {
        echo "<form method='post' class='ui form'>
              <div class='inline fields'>
                    <div class='six wide field'>
                        <input type='text' name='link-url-{$stL['step_link_id']}' placeholder='URL (unique)' value='{$stL['step_link_url']}'>
                    </div>
                    <div class='six wide field'>
                        <input type='text' name='link-name-{$stL['step_link_id']}' placeholder='Name' value='{$stL['step_link_name']}'>
                    </div>
                    <div class='three wide field'>
                        <input type='number' name='link-priority-{$stL['step_link_id']}' placeholder='Priority (unique)' value='{$stL['priority_nr']}'>
                    </div>
                    <div class='field'>
                        <button value='{$stL['step_link_id']}' name='edit-link-btn' class='ui green button' type='submit'>Edit</button>
                    </div>
                    <div class='field'>
                        <button value='{$stL['step_link_id']}' name='remove-link-btn' class='ui icon red button' type='submit'><i class='trash icon'></i></button>
                    </div>
              </div>
              </form>
        ";
    }
}

echo "</div>";
