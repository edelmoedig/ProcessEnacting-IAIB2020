<?php

namespace notifications;

function set($title, $message, $color) {
    $_SESSION['notification']['title'] = $title;
    $_SESSION['notification']['message'] = $message;
    $_SESSION['notification']['color'] = $color;
}

function unsetAll() {
    unset($_SESSION['notification']['title']);
    unset($_SESSION['notification']['message']);
    unset($_SESSION['notification']['color']);
}

function displayOnce() {
    if (isset($_SESSION['notification']['title']) && isset($_SESSION['notification']['message']) && isset($_SESSION['notification']['color'])) {
        include("./include/session_notification_toast.php");
    }
    unsetAll();
}
