<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.User" %>
<%@ page import="com.detection.model.Detection" %>
<%@ page import="com.detection.model.DetectionResult" %>
<%@ page import="com.detection.dao.DetectionDAO" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    int detectionId = -1;
    Detection d = null;
    try {
        detectionId = Integer.parseInt(idStr);
        DetectionDAO detectionDAO = new DetectionDAO();
        d = detectionDAO.getDetectionWithResults(detectionId);
    } catch (NumberFormatException e) {
        // Handled below
    }

    if (d == null || (d.getUserId() != currentUser.getId() && session.getAttribute("currentAdmin") == null)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detection Results - AI Vision Engine</title>
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
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h3 class="fw-bold text-white mb-0"><i class="bi bi-cpu text-primary"></i> Detection Scan #<%= d.getId() %></h3>
                    <a href="detectionHistory.jsp" class="btn btn-outline-light btn-sm"><i class="bi bi-arrow-left"></i> Back to History</a>
                </div>

                <!-- STATE 1: Pending or Processing Status Page -->
                <% if ("Pending".equals(d.getStatus()) || "Processing".equals(d.getStatus())) { %>
                    <div class="row justify-content-center">
                        <div class="col-lg-8">
                            <div class="glass-card p-4 p-md-5 text-center">
                                <div id="loaderWrapper">
                                    <div class="position-relative d-inline-block mb-4">
                                        <!-- Image preview thumbnail -->
                                        <img src="<%= d.getFilePath() %>" alt="Scanning File" class="rounded-3 border border-secondary" style="max-height: 250px; opacity: 0.6;">
                                        <!-- Sweeping Laser Scan Line -->
                                        <div class="scanner-overlay">
                                            <div class="scanner-line"></div>
                                        </div>
                                    </div>
                                    <h4 class="fw-bold text-white mb-2">Analyzing Image Data...</h4>
                                    <p id="pollStatusText" class="text-muted small">Status: Starting AI Engine model weights...</p>

                                    <!-- Progress Tracker -->
                                    <div class="d-flex align-items-center justify-content-between mb-2 mt-4 px-3">
                                        <span class="small text-muted fw-bold">Classification Confidence</span>
                                        <span id="pollProgressText" class="badge bg-primary p-2">0%</span>
                                    </div>
                                    <div class="progress-custom mb-3 mx-3">
                                        <div id="pollProgressBar" class="progress-bar-custom" style="width: 0%"></div>
                                    </div>
                                    <p class="text-muted small">The simulation runs in a background thread. This page will automatically reload on completion.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Trigger AJAX Polling for this detection ID -->
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            startStatusPolling(<%= d.getId() %>);
                        });
                    </script>

                <!-- STATE 2: Completed Result Page -->
                <% } else if ("Completed".equals(d.getStatus())) { %>
                    <div class="row g-4">
                        <!-- Left side: Overlaid canvas preview -->
                        <div class="col-xl-8">
                            <div class="glass-card p-3 text-center position-relative h-100 d-flex flex-column justify-content-center align-items-center">
                                <div class="d-flex justify-content-between w-100 mb-3 px-2">
                                    <span class="badge bg-success"><i class="bi bi-check-circle-fill"></i> Completed</span>
                                    <button class="btn btn-sm btn-outline-light" onclick="toggleCanvas()"><i class="bi bi-toggle-on"></i> Toggle Overlay</button>
                                </div>
                                <div class="detection-container position-relative">
                                    <!-- Rendered image -->
                                    <img id="resultImage" src="<%= d.getFilePath() %>" alt="Detection Result" class="detection-image">
                                    <!-- HTML5 Canvas Overlay -->
                                    <canvas id="resultCanvas" class="detection-canvas"></canvas>
                                </div>
                            </div>
                        </div>

                        <!-- Right side: Detection statistics list -->
                        <div class="col-xl-4">
                            <div class="glass-card p-4 h-100">
                                <h5 class="fw-bold text-white mb-3"><i class="bi bi-info-square-fill text-primary"></i> Scan Metadata</h5>
                                <div class="mb-4">
                                    <div class="d-flex justify-content-between border-bottom border-secondary py-2">
                                        <span class="text-muted small">File Name:</span>
                                        <span class="text-white small fw-bold"><%= d.getFileName() %></span>
                                    </div>
                                    <div class="d-flex justify-content-between border-bottom border-secondary py-2">
                                        <span class="text-muted small">Confidence Threshold:</span>
                                        <span class="text-white small fw-bold"><%= Math.round(d.getConfidenceThreshold() * 100) %>%</span>
                                    </div>
                                    <div class="d-flex justify-content-between border-bottom border-secondary py-2">
                                        <span class="text-muted small">Timestamp:</span>
                                        <span class="text-white small fw-bold"><%= d.getCreatedAt() %></span>
                                    </div>
                                    <div class="d-flex justify-content-between py-2">
                                        <span class="text-muted small">Description:</span>
                                        <span class="text-white small text-end"><%= d.getDescription() == null || d.getDescription().isEmpty() ? "No description" : d.getDescription() %></span>
                                    </div>
                                </div>

                                <h5 class="fw-bold text-white mb-3"><i class="bi bi-bounding-box text-primary"></i> Detected Objects (<%= d.getResults().size() %>)</h5>
                                <div style="max-height: 300px; overflow-y: auto;">
                                    <% if (d.getResults().isEmpty()) { %>
                                        <div class="alert alert-warning small py-2" role="alert">No objects detected above the threshold.</div>
                                    <% } else { %>
                                        <% for (DetectionResult res : d.getResults()) { %>
                                            <div class="glass-card p-3 mb-2 border border-secondary">
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <span class="fw-bold text-white"><%= res.getObjectName() %></span>
                                                    <span class="badge bg-primary"><%= Math.round(res.getConfidenceScore() * 100) %>% Match</span>
                                                </div>
                                                <div class="small text-muted">
                                                    Coordinates: X=<%= res.getBoxX() %>, Y=<%= res.getBoxY() %>, Width=<%= res.getBoxWidth() %>, Height=<%= res.getBoxHeight() %>
                                                </div>
                                            </div>
                                        <% } %>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- JSON array builder for bounding boxes -->
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            const results = [
                                <% for (int i = 0; i < d.getResults().size(); i++) { 
                                    DetectionResult r = d.getResults().get(i);
                                %>
                                    {
                                        objectName: "<%= r.getObjectName() %>",
                                        confidenceScore: <%= r.getConfidenceScore() %>,
                                        boxX: <%= r.getBoxX() %>,
                                        boxY: <%= r.getBoxY() %>,
                                        boxWidth: <%= r.getBoxWidth() %>,
                                        boxHeight: <%= r.getBoxHeight() %>
                                    }
                                    <% if (i < d.getResults().size() - 1) { %>,<% } %>
                                <% } %>
                            ];
                            
                            // Draw bounding boxes on Canvas over image
                            drawBoundingBoxes("resultCanvas", "resultImage", results);
                        });

                        function toggleCanvas() {
                            const canvas = document.getElementById("resultCanvas");
                            if (canvas) {
                                canvas.style.display = canvas.style.display === "none" ? "block" : "none";
                            }
                        }
                    </script>

                <!-- STATE 3: Failed Page -->
                <% } else { %>
                    <div class="row justify-content-center">
                        <div class="col-lg-6">
                            <div class="glass-card p-4 p-md-5 text-center">
                                <i class="bi bi-x-circle text-danger display-1 mb-3"></i>
                                <h4 class="fw-bold text-white">Detection Failed</h4>
                                <p class="text-muted small">An error occurred within the AI simulation thread engine. Please delete the record and try again.</p>
                                <a href="uploadDetection.jsp" class="btn btn-primary mt-3">Try Another Upload</a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
