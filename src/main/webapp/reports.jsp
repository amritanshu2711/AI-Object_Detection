<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.Admin" %>
<%@ page import="com.detection.model.Detection" %>
<%@ page import="com.detection.dao.DetectionDAO" %>
<%@ page import="java.util.List" %>
<%
    Admin currentAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
    if (currentAdmin == null) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    DetectionDAO detectionDAO = new DetectionDAO();
    List<Detection> reportsData = detectionDAO.getAllDetections();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platform Reports - AI Vision Engine</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom Style -->
    <link href="assets/css/style.css?v=2.0" rel="stylesheet">
    
    <style>
        /* CSS to hide navigation when printing reports */
        @media print {
            #sidebar-wrapper, .navbar-custom, .footer-custom, .print-hide {
                display: none !important;
            }
            #page-content-wrapper {
                margin-left: 0 !important;
                width: 100% !important;
                padding: 0 !important;
            }
            body {
                background: white !important;
                color: black !important;
            }
            .glass-card {
                background: transparent !important;
                border: none !important;
                box-shadow: none !important;
                color: black !important;
            }
            .table-custom {
                color: black !important;
            }
            .table-custom th {
                background: #f1f5f9 !important;
                color: black !important;
                border-bottom: 2px solid #cbd5e1 !important;
            }
            .table-custom td {
                border-bottom: 1px solid #cbd5e1 !important;
            }
        }
    </style>
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
                
                <div class="d-flex justify-content-between align-items-center mb-4 print-hide">
                    <div>
                        <h4 class="fw-bold text-white mb-1"><i class="bi bi-file-earmark-bar-graph-fill text-primary"></i> Platform Reports</h4>
                        <p class="text-muted mb-0 small">Filter detection logs, export data summaries, or print records</p>
                    </div>
                    
                    <div class="d-flex gap-2">
                        <button onclick="window.print()" class="btn btn-secondary"><i class="bi bi-printer-fill"></i> Print Report</button>
                        <button onclick="exportTableToCSV('ai-detection-report.csv')" class="btn btn-primary"><i class="bi bi-filetype-csv"></i> Export CSV</button>
                    </div>
                </div>

                <!-- Report parameters (Filter area) -->
                <div class="glass-card p-4 mb-4 print-hide">
                    <h6 class="fw-bold text-white mb-3"><i class="bi bi-funnel-fill text-primary"></i> Filter Report Data</h6>
                    <div class="row g-3">
                        <div class="col-md-3">
                            <label for="statusFilter" class="form-label text-muted small">Status</label>
                            <select id="statusFilter" class="form-select" onchange="filterReport()">
                                <option value="">All Statuses</option>
                                <option value="Completed">Completed</option>
                                <option value="Failed">Failed</option>
                                <option value="Processing">Processing</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label for="typeFilter" class="form-label text-muted small">Type</label>
                            <select id="typeFilter" class="form-select" onchange="filterReport()">
                                <option value="">All Types</option>
                                <option value="Image">Image</option>
                                <option value="Video">Video</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="searchFilter" class="form-label text-muted small">Search User or File Name</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-secondary text-muted"><i class="bi bi-search"></i></span>
                                <input type="text" id="searchFilter" class="form-control" placeholder="Search John, street.jpg, etc..." onkeyup="filterReport()">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Report Data Table -->
                <div class="glass-card p-4">
                    <div class="text-center d-none d-print-block mb-4">
                        <h2 class="fw-bold">AI Powered Object Detection System</h2>
                        <h4 class="text-muted">Platform Detections Report</h4>
                        <hr>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-custom border-0" id="reportTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>User Email</th>
                                    <th>User Name</th>
                                    <th>File Name</th>
                                    <th>Scan Type</th>
                                    <th>Threshold</th>
                                    <th>Status</th>
                                    <th>Timestamp</th>
                                </tr>
                            </thead>
                            <tbody id="reportTableBody">
                                <% if (reportsData.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">No records found on the system.</td>
                                    </tr>
                                <% } else { %>
                                    <% for (Detection d : reportsData) { %>
                                        <tr class="report-row">
                                            <td>#<%= d.getId() %></td>
                                            <td><strong><%= d.getUserEmail() %></strong></td>
                                            <td><%= d.getUserName() %></td>
                                            <td><%= d.getFileName() %></td>
                                            <td class="type-cell"><%= d.getDetectionType() %></td>
                                            <td><%= Math.round(d.getConfidenceThreshold() * 100) %>%</td>
                                            <td class="status-cell">
                                                <span class="badge bg-secondary"><%= d.getStatus() %></span>
                                            </td>
                                            <td class="small text-muted"><%= d.getCreatedAt() %></td>
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

    <script>
        // Dynamic client-side filtering matching search metrics
        function filterReport() {
            const statusVal = document.getElementById("statusFilter").value.toLowerCase();
            const typeVal = document.getElementById("typeFilter").value.toLowerCase();
            const searchVal = document.getElementById("searchFilter").value.toLowerCase();
            
            const rows = document.getElementsByClassName("report-row");

            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                const cells = row.getElementsByTagName("td");
                
                const userEmail = cells[1].textContent.toLowerCase();
                const userName = cells[2].textContent.toLowerCase();
                const fileName = cells[3].textContent.toLowerCase();
                const type = row.querySelector(".type-cell").textContent.toLowerCase();
                const status = row.querySelector(".status-cell").textContent.toLowerCase();

                // Validation logic checks
                const matchesStatus = statusVal === "" || status.includes(statusVal);
                const matchesType = typeVal === "" || type.includes(typeVal);
                const matchesSearch = searchVal === "" || 
                                      userEmail.includes(searchVal) || 
                                      userName.includes(searchVal) || 
                                      fileName.includes(searchVal);

                if (matchesStatus && matchesType && matchesSearch) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            }
        }

        // CSV export helper functions
        function exportTableToCSV(filename) {
            const csv = [];
            const rows = document.querySelectorAll("#reportTable tr");
            
            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                // Check if row is currently visible
                if (row.style.display === "none") continue;
                
                const cols = row.querySelectorAll("td, th");
                const rowData = [];
                
                for (let j = 0; j < cols.length; j++) {
                    // Strip tags and trim contents
                    let text = cols[j].textContent.replace(/"/g, '""').trim();
                    rowData.push('"' + text + '"');
                }
                csv.push(rowData.join(","));
            }

            // Download CSV link trigger
            const csvFile = new Blob([csv.join("\n")], { type: "text/csv" });
            const downloadLink = document.createElement("a");
            downloadLink.download = filename;
            downloadLink.href = window.URL.createObjectURL(csvFile);
            downloadLink.style.display = "none";
            document.body.appendChild(downloadLink);
            downloadLink.click();
            document.body.removeChild(downloadLink);
        }
    </script>

</body>
</html>
