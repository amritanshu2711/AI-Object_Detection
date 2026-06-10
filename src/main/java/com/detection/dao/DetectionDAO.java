package com.detection.dao;

import com.detection.conn.DBConnection;
import com.detection.model.Detection;
import com.detection.model.DetectionResult;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DetectionDAO {

    public int addDetection(Detection detection) {
        String query = "INSERT INTO detections (user_id, file_name, file_path, detection_type, description, confidence_threshold, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, detection.getUserId());
            ps.setString(2, detection.getFileName());
            ps.setString(3, detection.getFilePath());
            ps.setString(4, detection.getDetectionType());
            ps.setString(5, detection.getDescription());
            ps.setDouble(6, detection.getConfidenceThreshold());
            ps.setString(7, detection.getStatus());
            
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public Detection getDetectionById(int id) {
        String query = "SELECT d.*, u.full_name, u.email FROM detections d JOIN users u ON d.user_id = u.id WHERE d.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Detection d = new Detection();
                    d.setId(rs.getInt("id"));
                    d.setUserId(rs.getInt("user_id"));
                    d.setFileName(rs.getString("file_name"));
                    d.setFilePath(rs.getString("file_path"));
                    d.setDetectionType(rs.getString("detection_type"));
                    d.setDescription(rs.getString("description"));
                    d.setConfidenceThreshold(rs.getDouble("confidence_threshold"));
                    d.setStatus(rs.getString("status"));
                    d.setCreatedAt(rs.getTimestamp("created_at"));
                    d.setUserName(rs.getString("full_name"));
                    d.setUserEmail(rs.getString("email"));
                    return d;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Detection getDetectionWithResults(int id) {
        Detection detection = getDetectionById(id);
        if (detection != null) {
            DetectionResultDAO resultDAO = new DetectionResultDAO();
            List<DetectionResult> results = resultDAO.getResultsByDetectionId(id);
            detection.setResults(results);
        }
        return detection;
    }

    public List<Detection> getDetectionsByUser(int userId) {
        List<Detection> list = new ArrayList<>();
        String query = "SELECT * FROM detections WHERE user_id = ? ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Detection d = new Detection();
                    d.setId(rs.getInt("id"));
                    d.setUserId(rs.getInt("user_id"));
                    d.setFileName(rs.getString("file_name"));
                    d.setFilePath(rs.getString("file_path"));
                    d.setDetectionType(rs.getString("detection_type"));
                    d.setDescription(rs.getString("description"));
                    d.setConfidenceThreshold(rs.getDouble("confidence_threshold"));
                    d.setStatus(rs.getString("status"));
                    d.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Detection> getAllDetections() {
        List<Detection> list = new ArrayList<>();
        String query = "SELECT d.*, u.full_name, u.email FROM detections d JOIN users u ON d.user_id = u.id ORDER BY d.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Detection d = new Detection();
                d.setId(rs.getInt("id"));
                d.setUserId(rs.getInt("user_id"));
                d.setFileName(rs.getString("file_name"));
                d.setFilePath(rs.getString("file_path"));
                d.setDetectionType(rs.getString("detection_type"));
                d.setDescription(rs.getString("description"));
                d.setConfidenceThreshold(rs.getDouble("confidence_threshold"));
                d.setStatus(rs.getString("status"));
                d.setCreatedAt(rs.getTimestamp("created_at"));
                d.setUserName(rs.getString("full_name"));
                d.setUserEmail(rs.getString("email"));
                list.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Detection> searchDetections(String searchVal) {
        List<Detection> list = new ArrayList<>();
        String query = "SELECT d.*, u.full_name, u.email FROM detections d JOIN users u ON d.user_id = u.id " +
                       "WHERE d.file_name LIKE ? OR d.description LIKE ? OR d.status LIKE ? OR u.full_name LIKE ? OR u.email LIKE ? " +
                       "ORDER BY d.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            String searchPattern = "%" + searchVal + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Detection d = new Detection();
                    d.setId(rs.getInt("id"));
                    d.setUserId(rs.getInt("user_id"));
                    d.setFileName(rs.getString("file_name"));
                    d.setFilePath(rs.getString("file_path"));
                    d.setDetectionType(rs.getString("detection_type"));
                    d.setDescription(rs.getString("description"));
                    d.setConfidenceThreshold(rs.getDouble("confidence_threshold"));
                    d.setStatus(rs.getString("status"));
                    d.setCreatedAt(rs.getTimestamp("created_at"));
                    d.setUserName(rs.getString("full_name"));
                    d.setUserEmail(rs.getString("email"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int detectionId, String status) {
        String query = "UPDATE detections SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, status);
            ps.setInt(2, detectionId);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteDetection(int id) {
        String query = "DELETE FROM detections WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getDetectionsCountByUser(int userId) {
        String query = "SELECT COUNT(*) FROM detections WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==========================================
    // Analytics & Report Operations
    // ==========================================

    public Map<String, Integer> getCategoryStats() {
        Map<String, Integer> stats = new HashMap<>();
        String query = "SELECT object_name, COUNT(*) AS count FROM detection_results GROUP BY object_name ORDER BY count DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                stats.put(rs.getString("object_name"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    public Map<String, Integer> getDailyStats() {
        Map<String, Integer> stats = new HashMap<>();
        String query = "SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS date_val, COUNT(*) AS count " +
                       "FROM detections GROUP BY date_val ORDER BY date_val DESC LIMIT 7";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                stats.put(rs.getString("date_val"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    public Map<String, Integer> getMonthlyStats() {
        Map<String, Integer> stats = new HashMap<>();
        String query = "SELECT DATE_FORMAT(created_at, '%Y-%m') AS month_val, COUNT(*) AS count " +
                       "FROM detections GROUP BY month_val ORDER BY month_val DESC LIMIT 6";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                stats.put(rs.getString("month_val"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    public Map<String, Double> getAccuracyStats() {
        Map<String, Double> stats = new HashMap<>();
        String query = "SELECT object_name, AVG(confidence_score) * 100 AS avg_conf FROM detection_results GROUP BY object_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                stats.put(rs.getString("object_name"), rs.getDouble("avg_conf"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
}
