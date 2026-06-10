<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.Admin" %>
<%
    Admin currentAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
    if (currentAdmin == null) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Summary - AI Vision Engine</title>
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
                
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h4 class="fw-bold text-white mb-1"><i class="bi bi-bar-chart-line-fill text-primary"></i> Platform Analytics</h4>
                        <p class="text-muted mb-0 small">Visual metrics, detection accuracies, and usage statistics</p>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Chart 1: Object Frequency -->
                    <div class="col-lg-6">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-pie-chart text-primary"></i> Object Class Distribution</h5>
                            <div style="height: 300px; position: relative;">
                                <canvas id="distChart"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Chart 2: Daily Detections Volume (Last 7 Days) -->
                    <div class="col-lg-6">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-calendar-check text-primary"></i> Daily Scans (Last 7 Days)</h5>
                            <div style="height: 300px; position: relative;">
                                <canvas id="dailyAnalyticsChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4">
                    <!-- Chart 3: Monthly Volume Trends -->
                    <div class="col-lg-6">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-graph-up-arrow text-primary"></i> Monthly Traffic Trends</h5>
                            <div style="height: 300px; position: relative;">
                                <canvas id="monthlyChart"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Accuracy Table -->
                    <div class="col-lg-6">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold text-white mb-3"><i class="bi bi-bullseye text-primary"></i> Average Detection Confidence</h5>
                            
                            <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                                <table class="table table-custom border-0 mb-0">
                                    <thead>
                                        <tr>
                                            <th>Object Label</th>
                                            <th class="text-end">Average Score</th>
                                        </tr>
                                    </thead>
                                    <tbody id="accuracyTableBody">
                                        <tr>
                                            <td colspan="2" class="text-center text-muted py-4">Loading stats...</td>
                                        </tr>
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

    <!-- AJAX script to fetch datasets and render charts -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            fetch("admin-analytics-data")
                .then(response => response.json())
                .then(data => {
                    if (data.error) return;

                    // 1. Distribution Chart
                    const distData = data.categories;
                    new Chart(document.getElementById('distChart').getContext('2d'), {
                        type: 'pie',
                        data: {
                            labels: Object.keys(distData),
                            datasets: [{
                                data: Object.values(distData),
                                backgroundColor: ['#6366f1', '#10b981', '#3b82f6', '#f59e0b', '#ec4899', '#06b6d4', '#8b5cf6', '#14b8a6'],
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

                    // 2. Daily Chart
                    const dailyData = data.daily;
                    new Chart(document.getElementById('dailyAnalyticsChart').getContext('2d'), {
                        type: 'line',
                        data: {
                            labels: Object.keys(dailyData).reverse(),
                            datasets: [{
                                label: 'Scans Done',
                                data: Object.values(dailyData).reverse(),
                                borderColor: '#10b981',
                                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                                fill: true,
                                tension: 0.3
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: { legend: { display: false } },
                            scales: {
                                x: { ticks: { color: '#94a3b8', font: { family: 'Outfit' } } },
                                y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8', font: { family: 'Outfit' } } }
                            }
                        }
                    });

                    // 3. Monthly Chart
                    const monthlyData = data.monthly;
                    new Chart(document.getElementById('monthlyChart').getContext('2d'), {
                        type: 'line',
                        data: {
                            labels: Object.keys(monthlyData).reverse(),
                            datasets: [{
                                label: 'Scans Done',
                                data: Object.values(monthlyData).reverse(),
                                borderColor: '#3b82f6',
                                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                                fill: true,
                                tension: 0.3
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: { legend: { display: false } },
                            scales: {
                                x: { ticks: { color: '#94a3b8', font: { family: 'Outfit' } } },
                                y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8', font: { family: 'Outfit' } } }
                            }
                        }
                    });

                    // 4. Accuracy Table mapping
                    const accData = data.accuracy;
                    const tableBody = document.getElementById("accuracyTableBody");
                    let html = "";
                    const keys = Object.keys(accData);
                    
                    if (keys.length === 0) {
                        html = `<tr><td colspan="2" class="text-center text-muted py-3">No predictions made yet</td></tr>`;
                    } else {
                        keys.forEach(k => {
                            html += `
                                <tr>
                                    <td><strong>${k}</strong></td>
                                    <td class="text-end text-primary fw-bold">${accData[k]}%</td>
                                </tr>
                            `;
                        });
                    }
                    tableBody.innerHTML = html;
                })
                .catch(err => console.error("Error loading analytics: ", err));
        });
    </script>

</body>
</html>
