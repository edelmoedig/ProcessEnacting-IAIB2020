<?php

if (!$step['is_decision']) {
    if ($step['next_step_id'] && !empty($_GET['prev'])) {
        $buttons = "<div class='ui raised text container segment'>
                        <a href='edit.php?pr={$_GET['pr']}'><button class='ui teal button'><i class='angle double up icon'></i>FINISH</button></a>
                        <a href='edit_step.php?pr={$_GET['pr']}&step={$_GET['prev']}'><button class='ui teal button'><i class='angle left icon'></i>BACK</button></a>
                        <a href='edit_step.php?pr={$_GET['pr']}&step={$step['next_step_id']}&prev={$_GET['step']}'><button class='ui teal button'><i class='angle right icon'></i>NEXT STEP</button></a>
                    </div>
                ";
    } else if ($step['next_step_id'] && empty($_GET['prev'])) {
        $buttons = "<div class='ui raised text container segment'>
                        <a href='edit.php?pr={$_GET['pr']}'><button class='ui teal button'><i class='angle double up icon'></i>FINISH</button></a>
                        <a href='edit_step.php?pr={$_GET['pr']}&step={$step['next_step_id']}&prev={$_GET['step']}'><button class='ui teal button'><i class='angle right icon'></i>NEXT STEP</button></a>
                    </div>
                ";
    } else if (!$step['next_step_id'] && !empty($_GET['prev'])) {
        $buttons = "<div class='ui raised text container segment'>
                        <a href='edit.php?pr={$_GET['pr']}'><button class='ui teal button'><i class='angle double up icon'></i>FINISH</button></a>
                        <a href='edit_step.php?pr={$_GET['pr']}&step={$_GET['prev']}'><button class='ui teal button'><i class='angle left icon'></i>BACK</button></a>
                    </div>
                    <div class='ui raised text container segment'>
                        <a href='add_step.php?pr={$_GET['pr']}&prev={$step['step_id']}&type=action'><button class='ui green button' type='submit'>Add action</button></a>
                        <a href='add_step.php?pr={$_GET['pr']}&prev={$step['step_id']}&type=decision'><button class='ui green button' type='submit'>Add decision</button></a>
                        <a href='add_step.php?pr={$_GET['pr']}&prev={$step['step_id']}&type=parallel'><button class='ui green button' type='submit'>Add parallel activity</button></a>
                        <a href='connect_step.php?pr={$_GET['pr']}&step={$_GET['step']}&prev={$step['step_id']}'><button class='ui green button' type='submit'>Connect existing step</button></a>
                    </div>
                ";
    } else if (!$step['next_step_id'] && empty($_GET['prev'])) {
        $buttons = "<div class='ui raised text container segment'>
                        <a href='edit.php?pr={$_GET['pr']}'><button class='ui teal button'><i class='angle double up icon'></i>FINISH</button></a>
                    </div>
                    <div class='ui raised text container segment'>
                        <a href='add_step.php?pr={$_GET['pr']}&prev={$step['step_id']}&type=action'><button class='ui green button' type='submit'>Add action</button></a>
                        <a href='add_step.php?pr={$_GET['pr']}&prev={$step['step_id']}&type=decision'><button class='ui green button' type='submit'>Add decision</button></a>
                        <a href='add_step.php?pr={$_GET['pr']}&prev={$step['step_id']}&type=parallel'><button class='ui green button' type='submit'>Add parallel activity</button></a>
                        <a href='connect_step.php?pr={$_GET['pr']}&step={$_GET['step']}&prev={$step['step_id']}'><button class='ui green button' type='submit'>Connect existing step</button></a>
                    </div>
                ";
    }
} else if (empty($_GET['prev'])) {
    $buttons = "<div class='ui raised text container segment'><a href='edit.php?pr={$_GET['pr']}'><button class='ui teal button'><i class='angle double up icon'></i>FINISH</button></a></div>
                ";
} else if (!empty($_GET['prev'])) {
    $buttons = "<div class='ui raised text container segment'>
                    <a href='edit.php?pr={$_GET['pr']}'><button class='ui teal button'><i class='angle double up icon'></i>FINISH</button></a>
                    <a href='edit_step.php?pr={$_GET['pr']}&step={$_GET['prev']}'><button class='ui teal button'><i class='angle left icon'></i>BACK</button></a>
                </div>
                ";
}

echo $buttons;
