<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.Admin" %>
<%@ page import="com.detection.dao.AdminDAO" %>
<%@ page import="java.util.Map" %>
<%
    Admin currentAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
    if (currentAdmin == null) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    AdminDAO adminDAO = new AdminDAO();
    Map<String, Integer> stats = adminDAO.getDashboardStats();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - AI Vision Engine</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom Style -->
    <link href="assets/css/style.css?v=2.0" rel="stylesheet">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                
                <!-- Feedback Alerts -->
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

                <!-- Admin Welcome Banner -->
                <div class="glass-card p-4 mb-4">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h3 class="fw-bold text-white mb-1">Administrative Dashboard</h3>
                            <p class="text-muted mb-0">Monitor platform metrics, manage user records, clean invalid detections, and analyze results.</p>
                        </div>
                        <div class="col-md-4 text-md-end mt-3 mt-md-0">
                            <a href="admin-delete-invalid" class="btn btn-outline-danger btn-sm" onclick="return confirm('This will permanently delete all failed and stale pending detections. Proceed?')">
                                <i class="bi bi-trash-fill"></i> Clean Invalid Records
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Statistics cards with IDs for AJAX updates -->
                <div class="row g-4 mb-4">
                    <!-- Total Users -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="glass-card p-4 stat-card h-100 border-start border-primary border-4">
                            <h6 class="text-muted small uppercase fw-bold">Total Users</h6>
                            <h2 class="fw-bold text-white mb-1" id="statTotalUsers"><%= stats.get("totalUsers") %></h2>
                            <span class="text-muted small">Registered customers</span>
                            <i class="bi bi-people stat-icon text-primary"></i>
                        </div>
                    </div>

                    <!-- Total Detections -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="glass-card p-4 stat-card h-100 border-start border-info border-4">
                            <h6 class="text-muted small uppercase fw-bold">Total Detections</h6>
                            <h2 class="fw-bold text-white mb-1" id="statTotalDetections"><%= stats.get("totalDetections") %></h2>
                            <span class="text-muted small">All processed uploads</span>
                            <i class="bi bi-cpu stat-icon text-info"></i>
                        </div>
                    </div>

                    <!-- Today's Detections -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="glass-card p-4 stat-card h-100 border-start border-warning border-4">
                            <h6 class="text-muted small uppercase fw-bold">Today's Detections</h6>
                            <h2 class="fw-bold text-white mb-1" id="statTodayDetections"><%= stats.get("todayDetections") %></h2>
                            <span class="text-muted small">Scans run today</span>
                            <i class="bi bi-calendar-event stat-icon text-warning"></i>
                        </div>
                    </div>

                    <!-- Successful Detections -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="glass-card p-4 stat-card h-100 border-start border-success border-4">
                            <h6 class="text-muted small uppercase fw-bold">Successful Detections</h6>
                            <h2 class="fw-bold text-white mb-1" id="statSuccessfulDetections"><%= stats.get("successfulDetections") %></h2>
                            <span class="text-muted small">Status Completed runs</span>
                            <i class="bi bi-check-circle stat-icon text-success"></i>
                        </div>
                    </div>
                </div>

                <!-- Live Quick Analytics Preview -->
                <div class="row g-4">
                    <!-- Chart 1: Object Categories -->
                    <div class="col-lg-6">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-pie-chart-fill text-primary"></i> Most Detected Objects</h5>
                            <div style="height: 300px; position: relative;">
                                <canvas id="categoriesChart"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Chart 2: Daily Detections Volume -->
                    <div class="col-lg-6">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-graph-up text-primary"></i> Live Detection Traffic (Daily)</h5>
                            <div style="height: 300px; position: relative;">
                                <canvas id="dailyChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>

    <!-- Script to load and compile charts dynamically via AJAX -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Load live analytics data asynchronously
            fetch("admin-analytics-data")
                .then(response => response.json())
                .then(data => {
                    if (data.error) return;

                    // 1. Categories Pie Chart
                    const catData = data.categories;
                    const catLabels = Object.keys(catData);
                    const catValues = Object.values(catData);

                    const ctxCat = document.getElementById('categoriesChart').getContext('2d');
                    new Chart(ctxCat, {
                        type: 'doughnut',
                        data: {
                            labels: catLabels.length ? catLabels : ["No Data"],
                            datasets: [{
                                data: catValues.length ? catValues : [0],
                                backgroundColor: ['#6366f1', '#10b981', '#3b82f6', '#f59e0b', '#ec4899', '#06b6d4', '#8b5cf6', '#14b8a6'],
                                borderWidth: 1,
                                borderColor: 'rgba(255,255,255,0.08)'
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    position: 'right',
                                    labels: { color: '#94a3b8', font: { family: 'Outfit' } }
                                }
                            }
                        }
                    });

                    // 2. Daily Detections Bar Chart
                    const dailyData = data.daily;
                    const dailyLabels = Object.keys(dailyData).reverse(); // chronological order
                    const dailyValues = Object.values(dailyData).reverse();

                    const ctxDaily = document.getElementById('dailyChart').getContext('2d');
                    new Chart(ctxDaily, {
                        type: 'bar',
                        data: {
                            labels: dailyLabels.length ? dailyLabels : ["No Data"],
                            datasets: [{
                                label: 'Scans',
                                data: dailyValues.length ? dailyValues : [0],
                                backgroundColor: '#6366f1',
                                borderRadius: 5
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { display: false }
                            },
                            scales: {
                                x: { grid: { display: false }, ticks: { color: '#94a3b8', font: { family: 'Outfit' } } },
                                y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8', font: { family: 'Outfit' } } }
                            }
                        }
                    });
                })
                .catch(err => console.error("Error drawing dashboard charts: ", err));
        });
    </script>

</body>
</html>
