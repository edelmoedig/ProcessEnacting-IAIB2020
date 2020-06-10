<?php
header('Content-Type: text/html; charset=utf-8');

require "model/Administrator.php";
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
        $_SESSION['success'] = "You have successfully registered!";
        header("Location: login.php");
        exit;
    } catch (PDOException $e) {
        if ($e->getCode() == 23505) {
            $_SESSION['error'] = "This email address is already registered.";
        } else {
            $_SESSION['error'] = "There has been an error while registering this user.";
        }
    }
} else if (isset($_POST['submit'])) {
    $_SESSION['error'] = "Please fill all required fields.";
}

?>

<html lang="en">
<head>
    <title>Register</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="default.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
</head>
<body>
<?php include "include/navigation.php"; ?>
<div class="ui raised very padded text container segment">

        <h2>Register</h2>


    <?php
    if (isset($_SESSION['error'])) {
        echo <<<_END
        <div class="ui negative message">
            <div class="header">
                Registration error
            </div>

_END;
        echo "<p>" . $_SESSION['error'] . "</p></div>";
        unset($_SESSION['error']);
    }
    ?>

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
