package com.detection.model;

public class DetectionResult {
    private int id;
    private int detectionId;
    private String objectName;
    private double confidenceScore;
    private int boxX;
    private int boxY;
    private int boxWidth;
    private int boxHeight;

    public DetectionResult() {}

    public DetectionResult(int id, int detectionId, String objectName, double confidenceScore, 
                           int boxX, int boxY, int boxWidth, int boxHeight) {
        this.id = id;
        this.detectionId = detectionId;
        this.objectName = objectName;
        this.confidenceScore = confidenceScore;
        this.boxX = boxX;
        this.boxY = boxY;
        this.boxWidth = boxWidth;
        this.boxHeight = boxHeight;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getDetectionId() {
        return detectionId;
    }

    public void setDetectionId(int detectionId) {
        this.detectionId = detectionId;
    }

    public String getObjectName() {
        return objectName;
    }

    public void setObjectName(String objectName) {
        this.objectName = objectName;
    }

    public double getConfidenceScore() {
        return confidenceScore;
    }

    public void setConfidenceScore(double confidenceScore) {
        this.confidenceScore = confidenceScore;
    }

    public int getBoxX() {
        return boxX;
    }

    public void setBoxX(int boxX) {
        this.boxX = boxX;
    }

    public int getBoxY() {
        return boxY;
    }

    public void setBoxY(int boxY) {
        this.boxY = boxY;
    }

    public int getBoxWidth() {
        return boxWidth;
    }

    public void setBoxWidth(int boxWidth) {
        this.boxWidth = boxWidth;
    }

    public int getBoxHeight() {
        return boxHeight;
    }

    public void setBoxHeight(int boxHeight) {
        this.boxHeight = boxHeight;
    }
}
