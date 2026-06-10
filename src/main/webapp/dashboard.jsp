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
    int totalDetections = detectionDAO.getDetectionsCountByUser(currentUser.getId());
    List<Detection> recentDetections = detectionDAO.getDetectionsByUser(currentUser.getId());
    if (recentDetections.size() > 5) {
        recentDetections = recentDetections.subList(0, 5); // Show top 5 recent
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - AI Vision Engine</title>
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
                <!-- Welcome Banner -->
                <div class="glass-card p-4 mb-4">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h2 class="fw-bold text-white mb-1">Welcome Back, <%= currentUser.getFullName() %>!</h2>
                            <p class="text-muted mb-0">Monitor your system status, run new scans, and view object coordinates here.</p>
                        </div>
                        <div class="col-md-4 text-md-end mt-3 mt-md-0">
                            <a href="uploadDetection.jsp" class="btn btn-primary"><i class="bi bi-cloud-arrow-up-fill"></i> New Detection Scan</a>
                        </div>
                    </div>
                </div>

                <!-- Statistics cards -->
                <div class="row g-4 mb-4">
                    <div class="col-sm-6 col-lg-3">
                        <div class="glass-card p-4 stat-card h-100">
                            <h6 class="text-muted small uppercase fw-bold">My Detections</h6>
                            <h2 class="fw-bold text-white mb-2"><%= totalDetections %></h2>
                            <span class="text-muted small">Total files processed</span>
                            <i class="bi bi-cpu stat-icon"></i>
                        </div>
                    </div>
                    
                    <div class="col-sm-6 col-lg-3">
                        <div class="glass-card p-4 stat-card h-100">
                            <h6 class="text-muted small uppercase fw-bold">Active Subscriptions</h6>
                            <h2 class="fw-bold text-white mb-2">Free Plan</h2>
                            <span class="text-muted small">Access to 10 common labels</span>
                            <i class="bi bi-award stat-icon"></i>
                        </div>
                    </div>

                    <div class="col-sm-6 col-lg-3">
                        <div class="glass-card p-4 stat-card h-100">
                            <h6 class="text-muted small uppercase fw-bold">Confidence Threshold</h6>
                            <h2 class="fw-bold text-white mb-2">Adjustable</h2>
                            <span class="text-muted small">Filter weak predictions</span>
                            <i class="bi bi-sliders stat-icon"></i>
                        </div>
                    </div>

                    <div class="col-sm-6 col-lg-3">
                        <div class="glass-card p-4 stat-card h-100">
                            <h6 class="text-muted small uppercase fw-bold">Engine Latency</h6>
                            <h2 class="fw-bold text-white mb-2">~1.2s</h2>
                            <span class="text-muted small">Fast simulated inferences</span>
                            <i class="bi bi-activity stat-icon"></i>
                        </div>
                    </div>
                </div>

                <!-- Recent Detections List -->
                <div class="row">
                    <div class="col-12">
                        <div class="glass-card p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="fw-bold text-white mb-0"><i class="bi bi-clock-history text-primary"></i> Recent Detections</h5>
                                <a href="detectionHistory.jsp" class="text-primary text-decoration-none small">View All History <i class="bi bi-chevron-right"></i></a>
                            </div>

                            <div class="table-responsive">
                                <table class="table table-custom table-hover border-0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>File Name</th>
                                            <th>Type</th>
                                            <th>Threshold</th>
                                            <th>Status</th>
                                            <th>Created At</th>
                                            <th class="text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (recentDetections.isEmpty()) { %>
                                            <tr>
                                                <td colspan="7" class="text-center text-muted py-4">No recent detections found. Start by uploading an image!</td>
                                            </tr>
                                        <% } else { %>
                                            <% for (Detection d : recentDetections) { %>
                                                <tr>
                                                    <td>#<%= d.getId() %></td>
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
                                                        <a href="detectionResult.jsp?id=<%= d.getId() %>" class="btn btn-sm btn-secondary me-2"><i class="bi bi-eye"></i> View</a>
                                                        <a href="detection-delete?id=<%= d.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this record?')"><i class="bi bi-trash"></i> Delete</a>
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

</body>
</html>
