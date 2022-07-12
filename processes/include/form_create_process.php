<?php

if (!empty($_POST['process-name']) && !empty($_POST['process-description'])) {
    if (empty($_POST['process-password'])) {
        $password = null;
    } else {
        $password = $_POST['process-password'];
    }
    $process->createProcess($_POST['process-name'], $_POST['process-description'], $_SESSION['id'], $password);
    notifications\set('Successfully created', 'Process has been successfully created.', 'green');
    echo "<meta http-equiv='refresh' content='0'>";
    exit();
}

?>

<div class='ui raised text container segment'>
    <h2>Create a new process</h2>
    <form method="post" class="ui form" autocomplete="off">
        <div class="required field">
            <label>Process name</label>
            <input type="text" name="process-name" placeholder="Process name" autocomplete="off" required>
        </div>
        <div class="required field">
            <label>Description</label>
            <textarea name ="process-description" placeholder="Process description" autocomplete="off" required></textarea>
        </div>
        <div class="field">
            <label>Password</label>
            <input type="text" name="process-password" placeholder="Process password (optional)"autocomplete="off">
        </div>
        <button class="ui green button" type="submit">Submit</button>
    </form>
</div>
