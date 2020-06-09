<?php

$processLinks = $process->getProcessLinks($_GET['pr']);

try {
    if (isset($_POST['edit-link-btn'])) {
        $id = $_POST['edit-link-btn'];
        $process->editProcessLink($id, $_POST['link-url-' . $id], $_POST['link-name-' . $id], $_POST['link-priority-' . $id]);
        header("Refresh: 0");
        exit();
    } else if (isset($_POST['remove-link-btn'])) {
        $process->removeProcessLink($_POST['edit-link-btn']);
        header("Refresh: 0");
        exit();
    } else if (isset($_POST['add-link-btn'])) {
        $process->addProcessLink($pr['process_id'], $_POST['new-link-url'], $_POST['new-link-name'], $_POST['new-link-priority']);
        header("Refresh: 0");
        exit();
    }
} catch (PDOException $e) {
    header("Refresh: 0");
    exit();
}

echo "<div class='ui raised text container segment'>";
echo "<h3>Process links</h3><form method='post' class='ui form'>";
echo "
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
    ";
if (empty($processLinks)) {
    echo "<p>There are no associated process links.</p>";
} else {
    foreach ($processLinks as $prL) {
        echo "
              <div class='inline fields'>
                    <div class='six wide field'>
                        <input type='text' name='link-url-{$prL['process_link_id']}' placeholder='URL (unique)' value='{$prL['process_link_url']}'>
                    </div>
                    <div class='six wide field'>
                        <input type='text' name='link-name-{$prL['process_link_id']}' placeholder='Name' value='{$prL['process_link_name']}'>
                    </div>
                    <div class='three wide field'>
                        <input type='number' name='link-priority-{$prL['process_link_id']}' placeholder='Priority (unique)' value='{$prL['priority_nr']}'>
                    </div>
                    <div class='field'>
                        <button value='{$prL['process_link_id']}' name='edit-link-btn' class='ui green button' type='submit'>Edit</button>
                    </div>
                    <div class='field'>
                        <button value='{$prL['process_link_id']}' name='remove-link-btn' class='ui icon red button' type='submit'><i class='trash icon'></i></button>
                    </div>
              </div>
        ";
    }
}

echo "</div>";
