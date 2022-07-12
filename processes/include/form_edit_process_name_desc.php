<?php

if (isset($_POST['edit-btn'])) {
    if (!empty($_POST['process-name']) && !empty($_POST['process-description'])) {
        $process->changeProcessNameAndDescription($pr['process_id'], $_POST['process-name'], $_POST['process-description']);
        notifications\set('Successfully edited', 'Process has been successfully edited.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    }
}
echo
    "<div class='ui raised text container segment'>
        <h2>Editing process</h2>
        <form method='post' class='ui form' autocomplete='off'>
            <div class='required field'>
                <label>Process name</label>
                <input type='text' name='process-name' placeholder='Process name' autocomplete='off' value='{$pr['process_name']}' required>
            </div>
            <div class='required field'>
                <label>Description</label>
                <textarea name ='process-description' placeholder='Process description' autocomplete='off' required>{$pr['process_description']}</textarea>
            </div>
            <button name='edit-btn' class='ui green button' type='submit'>Submit</button>
        </form>
    </div>";

