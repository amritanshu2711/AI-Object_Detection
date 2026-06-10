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
        }
        try {
            // Load SQLite Driver
            Class.forName("org.sqlite.JDBC");
            System.out.println("SQLite JDBC Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("SQLite JDBC Driver not found in classpath!");
        }
    }

    /**
     * Set the database configuration dynamically (e.g., from web.xml context params)
     * Supporting environment variables DB_URL, DB_USER, DB_PASSWORD to override settings.
     */
    public static void initialize(String url, String user, String password) {
        String envUrl = System.getenv("DB_URL");
        String envUser = System.getenv("DB_USER");
        String envPassword = System.getenv("DB_PASSWORD");

        if (envUrl != null && !envUrl.trim().isEmpty()) {
            dbUrl = envUrl;
        } else if (url != null && !url.trim().isEmpty()) {
            dbUrl = url;
        }

        if (envUser != null && !envUser.trim().isEmpty()) {
            dbUser = envUser;
        } else if (user != null) {
            dbUser = user;
        }

        if (envPassword != null) {
            dbPassword = envPassword;
        } else if (password != null) {
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
