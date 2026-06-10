package com.detection.conn;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Default fallback values
    private static String dbUrl = "jdbc:mysql://localhost:3306/ai_detection_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static String dbUser = "root";
    private static String dbPassword = "Root"; // Default fallback password

    static {
        try {
            // Load MySQL Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Connector/J Driver not found in classpath!");
            e.printStackTrace();
        }
    }

    /**
     * Set the database configuration dynamically (e.g., from web.xml context params)
     */
    public static void initialize(String url, String user, String password) {
        if (url != null && !url.trim().isEmpty()) {
            dbUrl = url;
        }
        if (user != null) {
            dbUser = user;
        }
        if (password != null) {
            dbPassword = password;
        }
    }

    /**
     * Obtains a new database connection
     */
    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        } catch (SQLException e) {
            System.err.println("Database connection failed for URL: " + dbUrl);
            System.err.println("User: " + dbUser);
            throw e;
        }
    }
}
