package com.detection.dao;

import com.detection.conn.DBConnection;
import com.detection.model.Admin;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class AdminDAO {

    public Admin login(String username, String passwordHash) {
        String query = "SELECT id, username, full_name, created_at FROM admins WHERE username = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Admin admin = new Admin();
                    admin.setId(rs.getInt("id"));
                    admin.setUsername(rs.getString("username"));
                    admin.setFullName(rs.getString("full_name"));
                    admin.setCreatedAt(rs.getTimestamp("created_at"));
                    return admin;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Retrieves key dashboard metrics for Admin dashboard cards.
     */
    public Map<String, Integer> getDashboardStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("totalUsers", 0);
        stats.put("totalDetections", 0);
        stats.put("todayDetections", 0);
        stats.put("successfulDetections", 0);

        String usersQuery = "SELECT COUNT(*) FROM users";
        String detectionsQuery = "SELECT COUNT(*) FROM detections";
        String todayQuery = "SELECT COUNT(*) FROM detections WHERE DATE(created_at) = CURDATE()";
        String successQuery = "SELECT COUNT(*) FROM detections WHERE status = 'Completed'";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Total Users
            try (PreparedStatement ps = conn.prepareStatement(usersQuery);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalUsers", rs.getInt(1));
                }
            }
            // 2. Total Detections
            try (PreparedStatement ps = conn.prepareStatement(detectionsQuery);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalDetections", rs.getInt(1));
                }
            }
            // 3. Today's Detections
            try (PreparedStatement ps = conn.prepareStatement(todayQuery);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("todayDetections", rs.getInt(1));
                }
            }
            // 4. Successful Detections
            try (PreparedStatement ps = conn.prepareStatement(successQuery);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("successfulDetections", rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
}
