package com.detection.model;

import java.sql.Timestamp;
import java.util.List;

public class Detection {
    private int id;
    private int userId;
    private String fileName;
    private String filePath;
    private String detectionType; // "Image" or "Video"
    private String description;
    private double confidenceThreshold;
    private String status; // "Pending", "Processing", "Completed", "Failed"
    private Timestamp createdAt;
    
    // Joint fields for dashboard/admin convenience
    private String userName;
    private String userEmail;

    // Bounding Box Results
    private List<DetectionResult> results;

    public Detection() {}

    public Detection(int id, int userId, String fileName, String filePath, String detectionType, 
                     String description, double confidenceThreshold, String status, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.fileName = fileName;
        this.filePath = filePath;
        this.detectionType = detectionType;
        this.description = description;
        this.confidenceThreshold = confidenceThreshold;
        this.status = status;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getDetectionType() {
        return detectionType;
    }

    public void setDetectionType(String detectionType) {
        this.detectionType = detectionType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getConfidenceThreshold() {
        return confidenceThreshold;
    }

    public void setConfidenceThreshold(double confidenceThreshold) {
        this.confidenceThreshold = confidenceThreshold;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public List<DetectionResult> getResults() {
        return results;
    }

    public void setResults(List<DetectionResult> results) {
        this.results = results;
    }
}
