<?php

if (isset($_POST['edit-step-btn']) && !empty($_POST['step-description'])) {
    $process->changeStepDescription($step['step_id'], htmlspecialchars($_POST['step-description']));
    notifications\set('Successfully edited', 'Step has been successfully edited.', 'green');
    echo "<meta http-equiv='refresh' content='0'>";
    exit();
}


echo "<div class='ui raised text container segment'>
        <h3>Action step</h3>
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
