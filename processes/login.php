<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Administrator.php";
require "functions/notifications.php";
session_start();

if (isset($_SESSION['id'])) {
    header("Location: index.php");
    exit;
}

if (!empty($_POST["email"]) && !empty($_POST["password"])) {
    try {
        $result = (new Administrator)->login($_POST["email"], $_POST["password"]);
        if ($result) {
            notifications\set('Login success', 'You have successfully logged in!', 'green');
            $_SESSION['id'] = $result;
            header("Location: overview.php");
            exit;
        } else {
            notifications\set('Login error', 'User with this email and password is not registered.', 'red');
        }
    } catch (PDOException $e) {
        notifications\set('Login error', 'There has been an error while logging in.', 'red');
    }
}
?>

<html lang="en">
<head>
    <title>Login</title>
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
    <h2>Login</h2>
    <form class="ui form" method="post" action="#">
        <div class="required field">
            <label for="email">Email</label>
            <input id="email" type="email" name="email" placeholder="Your email" required>
        </div>
        <div class="required field">
            <label for="password">Password</label>
            <input id="password" type="password" name="password" placeholder="Your password" required>
        </div>
        <button class="ui button" type="submit">Login</button>
    </form>
</div>
</body>
</html>
