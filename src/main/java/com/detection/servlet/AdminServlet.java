package com.detection.servlet;

import com.detection.dao.AdminDAO;
import com.detection.dao.DetectionDAO;
import com.detection.dao.UserDAO;
import com.detection.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminServlet", urlPatterns = {
    "/admin-stats", 
    "/admin-analytics-data", 
    "/admin-delete-user", 
    "/admin-delete-invalid"
})
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AdminDAO adminDAO;
    private UserDAO userDAO;
    private DetectionDAO detectionDAO;

    public void init() {
        adminDAO = new AdminDAO();
        userDAO = new UserDAO();
        detectionDAO = new DetectionDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        
        if ("/admin-stats".equals(path)) {
            getStatsJSON(request, response);
        } else if ("/admin-analytics-data".equals(path)) {
            getAnalyticsJSON(request, response);
        } else if ("/admin-delete-user".equals(path)) {
            handleDeleteUser(request, response);
        } else if ("/admin-delete-invalid".equals(path)) {
            handleDeleteInvalidRecords(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void getStatsJSON(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            out.print("{\"error\":\"Unauthorized\"}");
            return;
        }

        Map<String, Integer> stats = adminDAO.getDashboardStats();
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"totalUsers\":").append(stats.get("totalUsers")).append(",");
        json.append("\"totalDetections\":").append(stats.get("totalDetections")).append(",");
        json.append("\"todayDetections\":").append(stats.get("todayDetections")).append(",");
        json.append("\"successfulDetections\":").append(stats.get("successfulDetections"));
        json.append("}");

        out.print(json.toString());
    }

    private void getAnalyticsJSON(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            out.print("{\"error\":\"Unauthorized\"}");
            return;
        }

        // Get analytics aggregates from DAO
        Map<String, Integer> categoryStats = detectionDAO.getCategoryStats();
        Map<String, Integer> dailyStats = detectionDAO.getDailyStats();
        Map<String, Integer> monthlyStats = detectionDAO.getMonthlyStats();
        Map<String, Double> accuracyStats = detectionDAO.getAccuracyStats();

        StringBuilder json = new StringBuilder();
        json.append("{");
        
        // 1. Category Detections
        json.append("\"categories\":{");
        appendMapToJSON(json, categoryStats);
        json.append("},");

        // 2. Daily Detections
        json.append("\"daily\":{");
        appendMapToJSON(json, dailyStats);
        json.append("},");

        // 3. Monthly Detections
        json.append("\"monthly\":{");
        appendMapToJSON(json, monthlyStats);
        json.append("},");

        // 4. Accuracy Stats
        json.append("\"accuracy\":{");
        int index = 0;
        for (Map.Entry<String, Double> entry : accuracyStats.entrySet()) {
            json.append("\"").append(entry.getKey()).append("\":").append(String.format("%.2f", entry.getValue()));
            if (index < accuracyStats.size() - 1) {
                json.append(",");
            }
            index++;
        }
        json.append("}");

        json.append("}");
        out.print(json.toString());
    }

    private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect("adminLogin.jsp");
            return;
        }

        String userIdStr = request.getParameter("id");
        if (userIdStr != null) {
            try {
                int userId = Integer.parseInt(userIdStr);
                userDAO.deleteUser(userId);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect("viewDetections.jsp"); // Redirect back to management console
    }

    private void handleDeleteInvalidRecords(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect("adminLogin.jsp");
            return;
        }

        // Delete detections with status = 'Failed' or 'Pending' (that are stale)
        try {
            List<com.detection.model.Detection> all = detectionDAO.getAllDetections();
            for (com.detection.model.Detection d : all) {
                if ("Failed".equals(d.getStatus()) || ("Pending".equals(d.getStatus()) && System.currentTimeMillis() - d.getCreatedAt().getTime() > 1000 * 60 * 10)) {
                    detectionDAO.deleteDetection(d.getId());
                }
            }
            session.setAttribute("successMsg", "All invalid, failed, or stale pending records were deleted successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Failed to clean invalid records.");
        }
        response.sendRedirect("adminDashboard.jsp");
    }

    private void appendMapToJSON(StringBuilder json, Map<String, Integer> map) {
        int index = 0;
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            json.append("\"").append(entry.getKey()).append("\":").append(entry.getValue());
            if (index < map.size() - 1) {
                json.append(",");
            }
            index++;
        }
    }
}
