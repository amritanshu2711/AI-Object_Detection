<%@ page import="com.detection.model.User" %>
<%@ page import="com.detection.model.Admin" %>
<%
    User sidebarUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    Admin sidebarAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
    String currentURI = request.getRequestURI();
%>
<div id="sidebar-wrapper">
    <div class="sidebar-heading text-center border-bottom border-secondary py-4">
        <i class="bi bi-eye-fill fs-4 text-primary d-block mb-2"></i>
        <span class="fs-6 fw-bold">AI OBJECT DETECTOR</span>
    </div>
    <div class="list-group list-group-flush mt-3">
        <% if (sidebarAdmin != null) { %>
            <!-- Admin Navigation -->
            <a href="adminDashboard.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("adminDashboard") ? "active" : "" %>">
                <i class="bi bi-speedometer2"></i> Dashboard
            </a>
            <a href="viewDetections.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("viewDetections") ? "active" : "" %>">
                <i class="bi bi-database-fill"></i> View Detections
            </a>
            <a href="analytics.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("analytics") ? "active" : "" %>">
                <i class="bi bi-bar-chart-line-fill"></i> View Analytics
            </a>
            <a href="reports.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("reports") ? "active" : "" %>">
                <i class="bi bi-file-earmark-bar-graph-fill"></i> Generate Reports
            </a>
            <a href="logout" class="list-group-item list-group-item-action text-danger mt-5">
                <i class="bi bi-box-arrow-right"></i> Logout
            </a>
        <% } else if (sidebarUser != null) { %>
            <!-- User Navigation -->
            <a href="dashboard.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("dashboard") ? "active" : "" %>">
                <i class="bi-house-door-fill"></i> Dashboard
            </a>
            <a href="uploadDetection.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("uploadDetection") ? "active" : "" %>">
                <i class="bi bi-cloud-arrow-up-fill"></i> Upload Image / Video
            </a>
            <a href="detectionHistory.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("detectionHistory") || currentURI.contains("detectionResult") ? "active" : "" %>">
                <i class="bi bi-clock-history"></i> Detection History
            </a>
            <a href="profile.jsp" class="list-group-item list-group-item-action <%= currentURI.contains("profile") ? "active" : "" %>">
                <i class="bi bi-person-fill-gear"></i> User Profile
            </a>
            <a href="logout" class="list-group-item list-group-item-action text-danger mt-5">
                <i class="bi bi-box-arrow-right"></i> Logout
            </a>
        <% } else { %>
            <!-- Guest Link -->
            <a href="login.jsp" class="list-group-item list-group-item-action">
                <i class="bi bi-box-arrow-in-right"></i> User Login
            </a>
            <a href="adminLogin.jsp" class="list-group-item list-group-item-action">
                <i class="bi bi-shield-lock-fill"></i> Admin Login
            </a>
        <% } %>
    </div>
</div>
