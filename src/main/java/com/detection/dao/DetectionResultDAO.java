package com.detection.dao;

import com.detection.conn.DBConnection;
import com.detection.model.DetectionResult;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DetectionResultDAO {

    public boolean addResult(DetectionResult result) {
        String query = "INSERT INTO detection_results (detection_id, object_name, confidence_score, box_x, box_y, box_width, box_height) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, result.getDetectionId());
            ps.setString(2, result.getObjectName());
            ps.setDouble(3, result.getConfidenceScore());
            ps.setInt(4, result.getBoxX());
            ps.setInt(5, result.getBoxY());
            ps.setInt(6, result.getBoxWidth());
            ps.setInt(7, result.getBoxHeight());
            
            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<DetectionResult> getResultsByDetectionId(int detectionId) {
        List<DetectionResult> list = new ArrayList<>();
        String query = "SELECT * FROM detection_results WHERE detection_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, detectionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DetectionResult r = new DetectionResult();
                    r.setId(rs.getInt("id"));
                    r.setDetectionId(rs.getInt("detection_id"));
                    r.setObjectName(rs.getString("object_name"));
                    r.setConfidenceScore(rs.getDouble("confidence_score"));
                    r.setBoxX(rs.getInt("box_x"));
                    r.setBoxY(rs.getInt("box_y"));
                    r.setBoxWidth(rs.getInt("box_width"));
                    r.setBoxHeight(rs.getInt("box_height"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean deleteResultsByDetection(int detectionId) {
        String query = "DELETE FROM detection_results WHERE detection_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, detectionId);
            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
