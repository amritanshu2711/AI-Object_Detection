<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.Admin" %>
<%@ page import="com.detection.model.User" %>
<%@ page import="com.detection.model.Detection" %>
<%@ page import="com.detection.dao.UserDAO" %>
<%@ page import="com.detection.dao.DetectionDAO" %>
<%@ page import="java.util.List" %>
<%
    Admin currentAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
    if (currentAdmin == null) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    DetectionDAO detectionDAO = new DetectionDAO();
    
    List<User> usersList = userDAO.getAllUsers();
    List<Detection> detectionsList = detectionDAO.getAllDetections();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Records - AI Vision Engine</title>
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
                
                <div class="glass-card p-4">
                    <h4 class="fw-bold text-white mb-3"><i class="bi bi-database-fill text-primary"></i> Data Record Management</h4>
                    
                    <!-- Navigation Tabs -->
                    <ul class="nav nav-tabs border-secondary mb-4" id="recordTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active text-white" id="users-tab" data-bs-toggle="tab" data-bs-target="#users" type="button" role="tab" aria-controls="users" aria-selected="true">
                                <i class="bi bi-people-fill"></i> Users (<%= usersList.size() %>)
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link text-white" id="detections-tab" data-bs-toggle="tab" data-bs-target="#detections" type="button" role="tab" aria-controls="detections" aria-selected="false">
                                <i class="bi bi-cpu-fill"></i> Detections (<%= detectionsList.size() %>)
                            </button>
                        </li>
                    </ul>

                    <!-- Tab Contents -->
                    <div class="tab-content" id="recordTabsContent">
                        
                        <!-- TAB 1: USERS LIST -->
                        <div class="tab-pane fade show active" id="users" role="tabpanel" aria-labelledby="users-tab">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted small">Manage registered users and accounts</span>
                                <input type="text" id="usersSearch" class="form-control" placeholder="Quick search users..." style="max-width: 250px;">
                            </div>
                            
                            <div class="table-responsive">
                                <table class="table table-custom table-hover border-0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Full Name</th>
                                            <th>Email</th>
                                            <th>Mobile Number</th>
                                            <th>Created At</th>
                                            <th class="text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="usersTableBody">
                                        <% if (usersList.isEmpty()) { %>
                                            <tr>
                                                <td colspan="6" class="text-center text-muted py-4">No users registered yet.</td>
                                            </tr>
                                        <% } else { %>
                                            <% for (User u : usersList) { %>
                                                <tr>
                                                    <td>#<%= u.getId() %></td>
                                                    <td><strong><%= u.getFullName() %></strong></td>
                                                    <td><%= u.getEmail() %></td>
                                                    <td><%= u.getMobileNumber() %></td>
                                                    <td class="small text-muted"><%= u.getCreatedAt() %></td>
                                                    <td class="text-center">
                                                        <a href="admin-delete-user?id=<%= u.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Deleting this user will cascadingly delete all their object detections, logs, and files. Are you sure?')"><i class="bi bi-trash"></i> Delete User</a>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- TAB 2: DETECTIONS LIST -->
                        <div class="tab-pane fade" id="detections" role="tabpanel" aria-labelledby="detections-tab">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted small">Inspect, view outputs, and clean invalid records</span>
                                <input type="text" id="detectionsSearch" class="form-control" placeholder="Quick search detections..." style="max-width: 250px;">
                            </div>

                            <div class="table-responsive">
                                <table class="table table-custom table-hover border-0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>User Email</th>
                                            <th>File Name</th>
                                            <th>Type</th>
                                            <th>Threshold</th>
                                            <th>Status</th>
                                            <th>Timestamp</th>
                                            <th class="text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="detectionsTableBody">
                                        <% if (detectionsList.isEmpty()) { %>
                                            <tr>
                                                <td colspan="8" class="text-center text-muted py-4">No detections recorded on the platform yet.</td>
                                            </tr>
                                        <% } else { %>
                                            <% for (Detection d : detectionsList) { %>
                                                <tr>
                                                    <td>#<%= d.getId() %></td>
                                                    <td class="small"><strong><%= d.getUserEmail() %></strong><br><span class="text-muted"><%= d.getUserName() %></span></td>
                                                    <td><%= d.getFileName() %></td>
                                                    <td>
                                                        <span class="badge bg-secondary p-2">
                                                            <% if ("Image".equals(d.getDetectionType())) { %>
                                                                <i class="bi bi-image"></i> Image
                                                            <% } else { %>
                                                                <i class="bi bi-film"></i> Video
                                                            <% } %>
                                                        </span>
                                                    </td>
                                                    <td><%= Math.round(d.getConfidenceThreshold() * 100) %>%</td>
                                                    <td>
                                                        <% if ("Completed".equals(d.getStatus())) { %>
                                                            <span class="badge bg-success bg-opacity-25 text-success p-2 border border-success border-opacity-50">Completed</span>
                                                        <% } else if ("Processing".equals(d.getStatus())) { %>
                                                            <span class="badge bg-warning bg-opacity-25 text-warning p-2 border border-warning border-opacity-50">Processing</span>
                                                        <% } else { %>
                                                            <span class="badge bg-danger bg-opacity-25 text-danger p-2 border border-danger border-opacity-50">Failed</span>
                                                        <% } %>
                                                    </td>
                                                    <td class="small text-muted"><%= d.getCreatedAt() %></td>
                                                    <td class="text-center">
                                                        <div class="d-flex justify-content-center gap-1">
                                                            <a href="detectionResult.jsp?id=<%= d.getId() %>" class="btn btn-sm btn-secondary"><i class="bi bi-eye"></i> View</a>
                                                            <a href="detection-delete?id=<%= d.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Permanently delete this detection run?')"><i class="bi bi-trash"></i> Delete</a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>
    
    <!-- Hook up dynamic search logic for tabs -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            setupDynamicSearch("usersSearch", "usersTableBody", true);
            setupDynamicSearch("detectionsSearch", "detectionsTableBody", true);
        });
    </script>

</body>
</html>
