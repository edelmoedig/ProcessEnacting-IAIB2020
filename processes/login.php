<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Administrator.php";
session_start();

if (isset($_SESSION['id'])) {
    header("Location: index.php");
    exit;
}

if (!empty($_POST["email"]) && !empty($_POST["password"])) {
    try {
        $result = (new Administrator)->login($_POST["email"], $_POST["password"]);
        if ($result) {
            $_SESSION['success'] = "You have successfully logged in!";
            $_SESSION['id'] = $result;
            header("Location: index.php");
            exit;
        } else {
            $_SESSION['error'] = "User with this email and password is not registered.";
        }
    } catch (PDOException $e) {
        $_SESSION['error'] = "There has been an error while logging in.";
    }
}
?>

<html lang="en">
<head>
    <title>Login</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>
<?php include "navigation.php"; ?>

<div class="ui raised very padded text container segment">

        <h2>Login</h2>

    <?php
    if (isset($_SESSION['error'])) {
        echo <<<_END
        <div class="ui negative message">
            <div class="header">
                Login error
            </div>

_END;
        echo "<p>" . $_SESSION['error'] . "</p></div>";
        unset($_SESSION['error']);
    }
    if (isset($_SESSION['success'])) {
        echo <<<_END
        <div class="ui positive message">
            <div class="header">
                Registration success
            </div>

_END;
        echo "<p>" . $_SESSION['success'] . "</p></div>";
        unset($_SESSION['success']);
    }
    ?>

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
