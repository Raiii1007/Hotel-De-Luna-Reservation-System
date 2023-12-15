<?php

include '../components/connect.php';

// Function to log actions
function logAction($admin_id, $action, $details) {
    global $conn;

    $insert_log = $conn->prepare("INSERT INTO audit_log (admin_id, action, details, created_at) VALUES (?, ?, ?, NOW())");
    $insert_log->execute([$admin_id, $action, $details]);
}

if(isset($_COOKIE['admin_id'])){
   $admin_id = $_COOKIE['admin_id'];
   // Log login action
   logAction($admin_id, 'Login', 'Admin logged in');
} else {
   $admin_id = '';
   header('location:login.php');
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
   <!-- ... your head content ... -->
</head>
<body>
   
<!-- header section starts  -->
<?php include '../components/admin_header.php'; ?>
<!-- header section ends -->

<!-- dashboard section starts  -->

<section class="dashboard">

   <h1 class="heading">dashboard</h1>

   <div class="box-container">

   <!-- ... your existing dashboard boxes ... -->

   </div>

</section>

<?php
// Log dashboard view action
logAction($admin_id, 'View', 'Admin viewed the dashboard');
?>

</body>
</html>
