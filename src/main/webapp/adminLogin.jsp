<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Portal - AI Vision Engine</title>
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
                        <i class="bi bi-shield-lock-fill text-danger fs-1 animate__animated animate__pulse animate__infinite"></i>
                        <h2 class="fw-bold text-white mt-2">Admin Portal</h2>
                        <p class="text-muted small">Sign in with administrative privileges</p>
                    </div>

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

                    <form action="admin-login" method="POST">
                        <!-- Username -->
                        <div class="mb-3">
                            <label for="username" class="form-label text-muted small">Username</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary border-end-0 text-muted"><i class="bi bi-person-badge"></i></span>
                                <input type="text" class="form-control border-start-0" id="username" name="username" placeholder="Enter administrative username" required>
                            </div>
                        </div>

                        <!-- Password -->
                        <div class="mb-4">
                            <label for="password" class="form-label text-muted small">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary border-end-0 text-muted"><i class="bi bi-key"></i></span>
                                <input type="password" class="form-control border-start-0" id="password" name="password" placeholder="••••••••" required>
                            </div>
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" class="btn btn-danger w-100 mb-3 py-2 fw-bold">Authenticate Admin</button>
                        
                        <div class="text-center mt-3">
                            <a href="login.jsp" class="text-primary text-decoration-none small"><i class="bi bi-arrow-left"></i> Return to Regular Login</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
