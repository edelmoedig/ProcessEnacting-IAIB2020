<?php

if (isset($_POST['password-btn'])) {
    if (!empty($_POST['process-password'])) {
        $process->changeProcessPassword($pr['process_id'], $_POST['process-password']);
        header("Refresh: 0");
        exit();
    } else {
        $process->changeProcessPassword($pr['process_id'], null);
        header("Refresh: 0");
        exit();
    }
}

if ($pr['has_password']) {
    $msg = 'This process is currently password-protected <i class="lock icon"></i>.';
} else {
    $msg = 'This process currently has no password.';
}

echo
    "<div class='ui raised text container segment'>
        <form method=\"post\" class=\"ui form\" autocomplete=\"off\">
            <h3>{$msg}</h3>
            <div class=\"required field\">
                <label>Process password. Leave empty to reset</label>
                <input type=\"text\" name='process-password' placeholder=\"Process password\" autocomplete=\"off\">
            </div>
            <button name='password-btn' class=\"ui green button\" type=\"submit\">Submit</button>
        </form>
    </div>";
