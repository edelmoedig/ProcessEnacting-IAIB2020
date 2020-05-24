<div class="ui centered grid">
    <div class="center aligned column">
        <div class="ui compact menu">
            <a class="item" href="index.php">
                Processes
            </a>
            <?php
            if (isset($_SESSION['id'])) {
                echo "<a class='item' href='logout.php'>
                Logout</a>";
            }
            if ($_SERVER['REQUEST_URI'] === '/processes/register.php' or $_SERVER['REQUEST_URI'] === '/processes/login.php') {
                echo "
                    <a class='item' href='register.php'>
                        Register
                    </a>
                    <a class='item' href='login.php'>
                        Login
                    </a>";
            }
            ?>
        </div>
    </div>
</div>
