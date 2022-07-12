<?php

if ($pr['first_step_id'] == null) {
    echo "
        <div class='ui raised text container segment'>
            <h3>First step</h3>
            <p>This process currently has no first step.</p>
            <a href='add_step.php?pr={$pr['process_id']}&type=action'><button class='ui green button' type='submit'>Add first action</button></a>
            <a href='add_step.php?pr={$pr['process_id']}&type=decision'><button class='ui green button' type='submit'>Add first decision</button></a>
            <a href='add_step.php?pr={$pr['process_id']}&type=parallel'><button class='ui green button' type='submit'>Add first parallel activity</button></a>
        </div>
    ";
} else {
    $step = $process -> getStep($pr['first_step_id']);
    if ($step['is_decision']) {
        $typeName = "Decision";
    } else if ($step['is_parallel_activity']) {
        $typeName = "Parallel activity";
    } else {
        $typeName = "Action";
    }
    echo "
        <div class='ui raised text container segment'>
            <h3>First step: {$typeName}</h3>
            <p>{$step['step_description']}</p>
            <a href='edit_step.php?pr={$pr['process_id']}&step={$step['step_id']}'><button class='ui green button' type='submit'>Edit step</button></a>
        </div>
    ";
}


