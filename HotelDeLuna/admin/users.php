<?php

include '../components/connect.php';

if(isset($_COOKIE['admin_id'])){
   $admin_id = $_COOKIE['admin_id'];
}else{
   $admin_id = '';
   header('location:login.php');
}

if(isset($_POST['delete'])){

   $delete_id = $_POST['delete_id'];
   $delete_id = filter_var($delete_id, FILTER_SANITIZE_STRING);

   $verify_delete = $conn->prepare("SELECT * FROM `users` WHERE id = ?");
   $verify_delete->execute([$delete_id]);

   if($verify_delete->rowCount() > 0){
      $delete_bookings = $conn->prepare("DELETE FROM `users` WHERE id = ?");
      $delete_bookings->execute([$delete_id]);
      $success_msg[] = 'users deleted!';
   }else{
      $warning_msg[] = 'users deleted already!';
   }

}

?>

<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta http-equiv="X-UA-Compatible" content="IE=edge">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>users</title>

   <!-- font awesome cdn link  -->
   <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">

   <!-- custom css file link  -->
   <link rel="stylesheet" href="../css/admin_style.css">

</head>
<body>
   
<!-- header section starts  -->
<?php include '../components/admin_header.php'; ?>
<!-- header section ends -->

<!-- messages section starts  -->

<section class="grid">

   <h1 class="heading">users</h1>

   <div class="box-container">

   <?php
      $select_users = $conn->prepare("SELECT * FROM `users`");
      $select_users->execute();
      if($select_users->rowCount() > 0){
         while($fetch_users = $select_users->fetch(PDO::FETCH_ASSOC)){
   ?>
   <div class="box">
      <p>guest_name : <span><?= $fetch_users['guest_name']; ?></span></p>
      <p>guest_email : <span><?= $fetch_users['guest_email']; ?></span></p>
      <p>guest_number : <span><?= $fetch_users['guest_number']; ?></span></p>
      <p>guest_message : <span><?= $fetch_users['guest_message']; ?></span></p>
      <form action="" method="POST">
         <input type="hidden" name="delete_id" value="<?= $fetch_users['users_id']; ?>">
         <input type="submit" value="delete users" onclick="return confirm('delete this users?');" name="delete" class="btn">
      </form>
      <form action="" method="POST">
         <input type="hidden" name="update_id" value="<?= $fetch_users['users_id']; ?>">
         <input type="submit" value="update users" onclick="return confirm('update this users?');" name="update" class="btn">
      </form>
   </div>
   <?php
      }
   }else{
   ?>
   <div class="box" style="text-align: center;">
      <p>no users found!</p>
      <a href="dashboard.php" class="btn">go to home</a>
   </div>
   <?php
      }
   ?>

   </div>

</section>

<!-- messages section ends -->
















<script src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert/2.1.2/sweetalert.min.js"></script>

<!-- custom js file link  -->
<script src="../js/admin_script.js"></script>

<?php include '../components/message.php'; ?>

</body>
</html>