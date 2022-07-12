<?php

if ($pr['current_status'] == 'On hold') {
    $buttons = "<button name='activate-btn' class='ui green button' type='submit'>Activate</button><button name='delete-btn' class='ui red button' type='submit'>Delete</button>";
} else if ($pr['current_status'] == 'Active') {
    $buttons = "<button name='deactivate-btn' class='ui orange button' type='submit'>Deactivate</button><button name='end-btn' class='ui red button' type='submit'>End</button>";
} else if ($pr['current_status'] == 'Inactive') {
    $buttons = "<button name='activate-btn' class='ui green button' type='submit'>Activate</button><button name='end-btn' class='ui red button' type='submit'>End</button>";
}

try {
    if (isset($_POST['activate-btn'])) {
        $process->activateProcess($pr['process_id']);
        notifications\set('Successfully edited', 'Status successfully changed.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['deactivate-btn'])) {
        $process->deactivateProcess($pr['process_id']);
        notifications\set('Successfully edited', 'Status successfully changed.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['end-btn'])) {
        $process->endProcess($pr['process_id']);
        notifications\set('Successfully edited', 'Status successfully changed.', 'green');
        echo "<meta http-equiv='refresh' content='0'>";
        exit();
    } else if (isset($_POST['delete-btn'])) {
        $process->deleteProcess($pr['process_id']);
        echo "<script>window.location = 'overview.php'</script>";
        exit();
    }
} catch (PDOException $e) {
    notifications\set('Error', 'There has been an error.', 'red');
    echo "<meta http-equiv='refresh' content='0'>";
}

echo "
    <div class='ui raised text container segment'>
        <h3>Current status: {$pr['current_status']}</h3>
            <form method='post'>
                {$buttons}
            </form>
        </form>
    </div>
    ";
