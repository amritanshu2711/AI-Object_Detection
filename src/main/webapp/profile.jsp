<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.User" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - AI Vision Engine</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom Style -->
    <link href="assets/css/style.css?v=2.0" rel="stylesheet">
</head>
<body>

    <div class="d-flex" id="wrapper">
        <!-- Sidebar -->
        <%@ include file="includes/sidebar.jsp" %>

        <!-- Page Content -->
        <div id="page-content-wrapper">
            <!-- Navbar -->
            <%@ include file="includes/navbar.jsp" %>

            <div class="container-fluid px-4 py-4">
                
                <!-- Notification Alerts -->
                <div class="row">
                    <div class="col-lg-10 mx-auto">
                        <% 
                            String errorMsg = (String) session.getAttribute("errorMsg");
                            if (errorMsg != null) { 
                                session.removeAttribute("errorMsg");
                        %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="bi bi-exclamation-triangle-fill"></i> <%= errorMsg %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>

                        <% 
                            String successMsg = (String) session.getAttribute("successMsg");
                            if (successMsg != null) { 
                                session.removeAttribute("successMsg");
                        %>
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <i class="bi bi-check-circle-fill"></i> <%= successMsg %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div class="row g-4 justify-content-center">
                    <!-- Profile Information Card -->
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-person-fill-gear text-primary"></i> Edit Profile Information</h5>
                            <hr class="border-secondary mb-4">
                            
                            <form action="user-profile-update" method="POST">
                                <div class="mb-3">
                                    <label class="form-label text-muted small">Email Address (Read-only)</label>
                                    <input type="email" class="form-control bg-dark border-secondary text-muted" value="<%= currentUser.getEmail() %>" readonly disabled>
                                </div>
                                <div class="mb-3">
                                    <label for="fullName" class="form-label text-muted small">Full Name</label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" value="<%= currentUser.getFullName() %>" required>
                                </div>
                                <div class="mb-4">
                                    <label for="mobileNumber" class="form-label text-muted small">Mobile Number</label>
                                    <input type="tel" class="form-control" id="mobileNumber" name="mobileNumber" value="<%= currentUser.getMobileNumber() %>" required>
                                </div>
                                <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">Update Details</button>
                            </form>
                        </div>
                    </div>

                    <!-- Change Password Card -->
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-key-fill text-primary"></i> Security &amp; Password</h5>
                            <hr class="border-secondary mb-4">

                            <form action="user-password-change" method="POST">
                                <div class="mb-3">
                                    <label for="currentPassword" class="form-label text-muted small">Current Password</label>
                                    <input type="password" class="form-control" id="currentPassword" name="currentPassword" placeholder="Confirm current password" required>
                                </div>
                                <div class="mb-3">
                                    <label for="newPassword" class="form-label text-muted small">New Password</label>
                                    <input type="password" class="form-control" id="newPassword" name="newPassword" placeholder="Min 6 characters" required>
                                </div>
                                <div class="mb-4">
                                    <label for="confirmNewPassword" class="form-label text-muted small">Confirm New Password</label>
                                    <input type="password" class="form-control" id="confirmNewPassword" name="confirmNewPassword" placeholder="Repeat new password" required>
                                </div>
                                <button type="submit" class="btn btn-secondary w-100 py-2 fw-bold">Update Password</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
