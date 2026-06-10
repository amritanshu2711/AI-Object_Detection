<%@ page import="com.detection.model.User" %>
<%@ page import="com.detection.model.Admin" %>
<%
    User navUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    Admin navAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
%>
<nav class="navbar navbar-expand-lg navbar-dark navbar-custom sticky-top">
    <div class="container-fluid">
        <% if (navUser != null || navAdmin != null) { %>
            <button class="btn btn-outline-light me-3" id="menu-toggle">
                <i class="bi bi-list"></i>
            </button>
        <% } %>
        
        <a class="navbar-brand d-flex align-items-center gap-2" href="index.jsp">
            <i class="bi bi-cpu text-primary fs-3 animate__animated animate__pulse animate__infinite"></i>
            <span class="fw-bold bg-gradient text-white">AI Vision Engine</span>
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-center gap-3">
                <% if (navAdmin != null) { %>
                    <!-- Admin Navigation -->
                    <li class="nav-item">
                        <span class="badge bg-danger p-2 fs-7"><i class="bi bi-shield-lock-fill"></i> Admin Console</span>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-white d-flex align-items-center gap-2" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-person-circle fs-5 text-secondary"></i> <%= navAdmin.getFullName() %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark p-2 rounded-3 border-secondary" aria-labelledby="adminDropdown">
                            <li><a class="dropdown-item py-2" href="adminDashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                            <li><a class="dropdown-item py-2" href="viewDetections.jsp"><i class="bi bi-database-fill"></i> Manage Detections</a></li>
                            <li><a class="dropdown-item py-2" href="analytics.jsp"><i class="bi bi-bar-chart-line-fill"></i> Analytics</a></li>
                            <li><hr class="dropdown-divider border-secondary"></li>
                            <li><a class="dropdown-item py-2 text-danger" href="logout"><i class="bi bi-box-arrow-right"></i> Logout</a></li>
                        </ul>
                    </li>
                <% } else if (navUser != null) { %>
                    <!-- User Navigation -->
                    <li class="nav-item dropdown position-relative">
                        <a class="nav-link text-white me-2" href="#" id="notificationDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-bell-fill fs-5"></i>
                            <span id="notificationBadge" class="badge-notify d-none">0</span>
                        </a>
                        <div class="dropdown-menu dropdown-menu-end notification-dropdown p-0" id="notificationList" aria-labelledby="notificationDropdown">
                            <div class="dropdown-item text-center text-muted py-3">Loading notifications...</div>
                        </div>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-white d-flex align-items-center gap-2" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-person-circle fs-5 text-primary"></i> <%= navUser.getFullName() %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark p-2 rounded-3 border-secondary" aria-labelledby="userDropdown">
                            <li><a class="dropdown-item py-2" href="dashboard.jsp"><i class="bi bi-house-door-fill"></i> Dashboard</a></li>
                            <li><a class="dropdown-item py-2" href="uploadDetection.jsp"><i class="bi bi-cloud-arrow-up-fill"></i> New Detection</a></li>
                            <li><a class="dropdown-item py-2" href="detectionHistory.jsp"><i class="bi bi-clock-history"></i> History</a></li>
                            <li><a class="dropdown-item py-2" href="profile.jsp"><i class="bi bi-person-fill-gear"></i> My Profile</a></li>
                            <li><hr class="dropdown-divider border-secondary"></li>
                            <li><a class="dropdown-item py-2 text-danger" href="logout"><i class="bi bi-box-arrow-right"></i> Logout</a></li>
                        </ul>
                    </li>
                <% } else { %>
                    <!-- Guest Navigation -->
                    <li class="nav-item">
                        <a class="nav-link text-muted" href="login.jsp">Sign In</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-primary" href="register.jsp">Create Account</a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>
