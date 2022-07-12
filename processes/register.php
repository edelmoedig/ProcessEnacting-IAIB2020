<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Administrator.php";
require "functions/notifications.php";
session_start();

if (isset($_SESSION['id'])) {
    header("Location: index.php");
    exit;
}

if (!empty($_POST["email"]) && !empty($_POST["password"]) && (!empty($_POST["givenName"]) || !empty($_POST["surname"]))) {
    try {
        $givenName = empty($_POST["givenName"]) ? null : htmlspecialchars($_POST["givenName"]);
        $surname = empty($_POST["surname"]) ? null : htmlspecialchars($_POST["surname"]);
        (new Administrator)->register($_POST["email"], $_POST["password"], $givenName, $surname);
        notifications\set('Registration success', 'You have successfully registered!', 'green');
        header("Location: login.php");
        exit;
    } catch (PDOException $e) {
        if ($e->getCode() == 23505) {
            notifications\set('Registration error', 'This email address is already registered.', 'red');
        } else {
            notifications\set('Registration error', 'There has been an error while registering this user.', 'red');
        }
    }
} else if (isset($_POST['submit'])) {
    notifications\set('Registration error', 'Please fill all of the required fields.', 'red');
}
?>

<html lang="en">
<head>
    <title>Register</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="default.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.6/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>

<?php include "include/navigation.php"; ?>
<?php notifications\displayOnce(); ?>

<div class="ui raised very padded text container segment">
    <h2>Register</h2>
    <form id="#regForm" class="ui form" method="post" action="#">
        <div class="required field">
            <label for="email">Email</label>
            <input id="email" type="email" name="email" placeholder="Your email" required>
        </div>
        <div class="required field">
            <label for="password">Password</label>
            <input id="password" type="password" name="password" placeholder="Your password" required>
        </div>
        <div class="field">
            <label for="givenName">Given name</label>
            <input id="givenName" type="text" name="givenName"
                   placeholder="Your given name. Please fill at least one of the two name fields">
        </div>
        <div class="field">
            <label for="surname">Surname</label>
            <input id="surname" type="text" name="surname"
                   placeholder="Your surname. Please fill at least one of the two name fields">
        </div>
        <button class="ui button" type="submit" name="submit">Register</button>
    </form>
</div>
</body>
</html>
