<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.User" %>
<%@ page import="com.detection.model.Admin" %>
<%
    User indexUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    Admin indexAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Powered Object Detection System</title>
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
        <div class="row align-items-center justify-content-between g-5">
            <!-- Left Grid Hero Section -->
            <div class="col-lg-6 text-center text-lg-start">
                <h1 class="display-4 fw-extrabold text-white mb-3">
                    Analyze Visuals Instantly With <br>
                    <span class="bg-gradient text-transparent bg-clip-text fw-bold text-primary">Advanced AI Vision</span>
                </h1>
                <p class="lead text-muted mb-4 fs-5">
                    Our platform executes simulated real-time deep learning model architectures to recognize, locate, and outline objects in images and videos with absolute precision.
                </p>
                <div class="d-flex flex-wrap gap-3 justify-content-center justify-content-lg-start">
                    <% if (indexUser != null) { %>
                        <a href="dashboard.jsp" class="btn btn-primary btn-lg"><i class="bi bi-speedometer2"></i> User Dashboard</a>
                        <a href="uploadDetection.jsp" class="btn btn-outline-light btn-lg"><i class="bi bi-cloud-arrow-up-fill"></i> Upload File</a>
                    <% } else if (indexAdmin != null) { %>
                        <a href="adminDashboard.jsp" class="btn btn-primary btn-lg"><i class="bi bi-shield-lock-fill"></i> Admin Console</a>
                    <% } else { %>
                        <a href="register.jsp" class="btn btn-primary btn-lg">Get Started Free</a>
                        <a href="login.jsp" class="btn btn-outline-light btn-lg">Sign In</a>
                    <% } %>
                </div>
            </div>

            <!-- Right Grid Image preview scanner -->
            <div class="col-lg-5 text-center">
                <div class="glass-card p-3 d-inline-block">
                    <div class="detection-container position-relative">
                        <!-- Mock visual preview -->
                        <img id="heroPreviewImg" src="https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80" alt="Object Detection Demo" class="detection-image img-fluid rounded-3" style="max-height: 350px;">
                        <div class="scanner-overlay">
                            <div class="scanner-line"></div>
                        </div>
                        <canvas id="heroPreviewCanvas" class="detection-canvas"></canvas>
                    </div>
                    <div class="text-start mt-3 px-2">
                        <span class="badge bg-primary p-2 mb-2"><i class="bi bi-info-circle-fill"></i> Simulation Preview</span>
                        <p class="small text-muted mb-0">Objects recognized: <strong>Laptop</strong> (94%), <strong>Coffee Cup</strong> (89%), <strong>Keyboard</strong> (82%)</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Features grid -->
        <div class="row g-4 mt-5 pt-4">
            <div class="col-md-4">
                <div class="glass-card p-4 h-100 text-center text-md-start">
                    <div class="bg-primary bg-opacity-10 d-inline-block p-3 rounded-3 mb-3 text-primary">
                        <i class="bi bi-lightning-charge-fill fs-3"></i>
                    </div>
                    <h3 class="h5 fw-bold text-white">Real-Time Mock Execution</h3>
                    <p class="text-muted small">Incremental percentage-based status trackers keep you up to date on models scanning and detecting components asynchronously.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="glass-card p-4 h-100 text-center text-md-start">
                    <div class="bg-primary bg-opacity-10 d-inline-block p-3 rounded-3 mb-3 text-primary">
                        <i class="bi bi-bounding-box-circles fs-3"></i>
                    </div>
                    <h3 class="h5 fw-bold text-white">Precision Canvas Coordinates</h3>
                    <p class="text-muted small">Outputs bounding boxes dynamically onto images using HTML5 Canvas mapping functions supporting browser size adjustments.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="glass-card p-4 h-100 text-center text-md-start">
                    <div class="bg-primary bg-opacity-10 d-inline-block p-3 rounded-3 mb-3 text-primary">
                        <i class="bi bi-file-bar-graph-fill fs-3"></i>
                    </div>
                    <h3 class="h5 fw-bold text-white">Full Admin reporting</h3>
                    <p class="text-muted small">Dedicated admin dashboard charts displaying category-wise counts, accuracy trends, daily traffic, and export tables.</p>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>
    
    <script>
        // Draw some mock coordinates on the landing page hero image for a spectacular visual first impression!
        document.addEventListener("DOMContentLoaded", function() {
            setTimeout(() => {
                const results = [
                    { objectName: "Laptop", confidenceScore: 0.94, boxX: 100, boxY: 120, boxWidth: 320, boxHeight: 250 },
                    { objectName: "Bottle", confidenceScore: 0.88, boxX: 450, boxY: 80, boxWidth: 100, boxHeight: 180 }
                ];
                drawBoundingBoxes("heroPreviewCanvas", "heroPreviewImg", results);
            }, 600);
        });
    </script>

</body>
</html>
