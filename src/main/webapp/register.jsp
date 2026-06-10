<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - AI Vision Engine</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom Style -->
    <link href="assets/css/style.css?v=2.0" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100">

    <%@ include file="includes/navbar.jsp" %>

    <div class="container my-auto py-5">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="glass-card p-4 p-md-5">
                    <div class="text-center mb-4">
                        <i class="bi bi-person-plus-fill text-primary fs-1"></i>
                        <h2 class="fw-bold text-white mt-2">Create Account</h2>
                        <p class="text-muted small">Sign up to get access to AI Object Detection</p>
                    </div>

                    <!-- Client-Side Javascript Error Alerts -->
                    <div id="validationErrors" class="alert alert-danger d-none" role="alert"></div>

                    <!-- Backend Servlet Feedback Alerts -->
                    <% 
                        String errorMsg = (String) request.getAttribute("errorMsg");
                        if (errorMsg != null) { 
                    %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-triangle-fill"></i> <%= errorMsg %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <form action="user-register" method="POST" onsubmit="return validateRegisterForm();">
                        <!-- Full Name -->
                        <div class="mb-3">
                            <label for="fullName" class="form-label text-muted small">Full Name</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary border-end-0 text-muted"><i class="bi bi-person"></i></span>
                                <input type="text" class="form-control border-start-0" id="fullName" name="fullName" placeholder="Enter your full name" required>
                            </div>
                        </div>

                        <!-- Email -->
                        <div class="mb-3">
                            <label for="email" class="form-label text-muted small">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                                <input type="email" class="form-control border-start-0" id="email" name="email" placeholder="Enter your email address" required>
                            </div>
                        </div>

                        <!-- Mobile Number -->
                        <div class="mb-3">
                            <label for="mobileNumber" class="form-label text-muted small">Mobile Number</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary border-end-0 text-muted"><i class="bi bi-telephone"></i></span>
                                <input type="tel" class="form-control border-start-0" id="mobileNumber" name="mobileNumber" placeholder="Enter your mobile number" required>
                            </div>
                        </div>

                        <!-- Password -->
                        <div class="mb-3">
                            <label for="password" class="form-label text-muted small">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                                <input type="password" class="form-control border-start-0" id="password" name="password" placeholder="Min 6 characters" required>
                            </div>
                        </div>

                        <!-- Confirm Password -->
                        <div class="mb-4">
                            <label for="confirmPassword" class="form-label text-muted small">Confirm Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary border-end-0 text-muted"><i class="bi bi-shield-check"></i></span>
                                <input type="password" class="form-control border-start-0" id="confirmPassword" name="confirmPassword" placeholder="Repeat password" required>
                            </div>
                        </div>

                        <!-- Submit Buttons -->
                        <button type="submit" class="btn btn-primary w-100 mb-3 py-2 fw-bold">Register</button>
                        
                        <div class="text-center mt-3">
                            <p class="small text-muted mb-0">Already have an account? <a href="login.jsp" class="text-primary text-decoration-none">Sign In</a></p>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
