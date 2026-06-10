<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.User" %>
<%@ page import="com.detection.model.Detection" %>
<%@ page import="com.detection.dao.DetectionDAO" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    DetectionDAO detectionDAO = new DetectionDAO();
    List<Detection> history = detectionDAO.getDetectionsByUser(currentUser.getId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detection History - AI Vision Engine</title>
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
                    <div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
                        <div>
                            <h4 class="fw-bold text-white mb-1"><i class="bi bi-clock-history text-primary"></i> Detection History</h4>
                            <p class="text-muted mb-0 small">Search and manage all your processed and pending media scans</p>
                        </div>
                        
                        <!-- Search Box for Dynamic Filtering -->
                        <div class="input-group style-search" style="max-width: 300px;">
                            <span class="input-group-text bg-transparent border-secondary text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" id="historySearch" class="form-control" placeholder="Search files or status...">
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-custom table-hover border-0">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>File Preview</th>
                                    <th>File Name</th>
                                    <th>Scan Type</th>
                                    <th>Description</th>
                                    <th>Threshold</th>
                                    <th>Status</th>
                                    <th>Created At</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody id="historyTableBody">
                                <% if (history.isEmpty()) { %>
                                    <tr>
                                        <td colspan="9" class="text-center text-muted py-5">
                                            <i class="bi bi-folder2-open fs-2 mb-2 d-block text-secondary"></i>
                                            No detection runs recorded. <a href="uploadDetection.jsp" class="text-primary text-decoration-none fw-bold">Upload a file</a> to get started.
                                        </td>
                                    </tr>
                                <% } else { %>
                                    <% for (Detection d : history) { %>
                                        <tr>
                                            <td>#<%= d.getId() %></td>
                                            <td>
                                                <img src="<%= d.getFilePath() %>" alt="Scan thumbnail" class="rounded border border-secondary" style="width: 50px; height: 40px; object-fit: cover;">
                                            </td>
                                            <td><strong><%= d.getFileName() %></strong></td>
                                            <td>
                                                <span class="badge bg-secondary p-2">
                                                    <% if ("Image".equals(d.getDetectionType())) { %>
                                                        <i class="bi bi-image"></i> Image
                                                    <% } else { %>
                                                        <i class="bi bi-film"></i> Video
                                                    <% } %>
                                                </span>
                                            </td>
                                            <td class="small text-muted text-truncate" style="max-width: 150px;"><%= d.getDescription() == null || d.getDescription().isEmpty() ? "No description" : d.getDescription() %></td>
                                            <td><%= Math.round(d.getConfidenceThreshold() * 100) %>%</td>
                                            <td>
                                                <% if ("Completed".equals(d.getStatus())) { %>
                                                    <span class="badge bg-success bg-opacity-25 text-success p-2 border border-success border-opacity-50"><i class="bi bi-check-circle-fill"></i> Completed</span>
                                                <% } else if ("Processing".equals(d.getStatus())) { %>
                                                    <span class="badge bg-warning bg-opacity-25 text-warning p-2 border border-warning border-opacity-50"><i class="bi bi-arrow-repeat animate-spin"></i> Processing</span>
                                                <% } else { %>
                                                    <span class="badge bg-danger bg-opacity-25 text-danger p-2 border border-danger border-opacity-50"><i class="bi bi-x-circle-fill"></i> Failed</span>
                                                <% } %>
                                            </td>
                                            <td class="small text-muted"><%= d.getCreatedAt() %></td>
                                            <td class="text-center">
                                                <div class="d-flex justify-content-center gap-1">
                                                    <a href="detectionResult.jsp?id=<%= d.getId() %>" class="btn btn-sm btn-secondary"><i class="bi bi-eye"></i> View</a>
                                                    <a href="detection-delete?id=<%= d.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this record?')"><i class="bi bi-trash"></i> Delete</a>
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

    <%@ include file="includes/footer.jsp" %>
    
    <!-- Hook up dynamic client search filter -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            setupDynamicSearch("historySearch", "historyTableBody", false);
        });
    </script>

</body>
</html>
