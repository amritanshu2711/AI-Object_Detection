package com.detection.listener;

import com.detection.conn.DBConnection;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        
        // Fetch variables from Env first, fallback to web.xml
        String dbUrl = System.getenv("DB_URL");
        String dbUser = System.getenv("DB_USER");
        String dbPassword = System.getenv("DB_PASSWORD");
        
        if (dbUrl == null || dbUrl.trim().isEmpty()) {
            dbUrl = context.getInitParameter("db.url");
        }
        if (dbUser == null) {
            dbUser = context.getInitParameter("db.username");
        }
        if (dbPassword == null) {
            dbPassword = context.getInitParameter("db.password");
        }
        
        boolean connectionOk = false;
        
        // Test primary database connection if it is not SQLite
        if (dbUrl != null && !dbUrl.trim().isEmpty() && !dbUrl.startsWith("jdbc:sqlite:")) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                // Set short login timeout of 4 seconds to check database health
                DriverManager.setLoginTimeout(4);
                try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
                    connectionOk = true;
                    System.out.println("AI Object Detection: Configured primary database connection successful: " + dbUrl);
                }
            } catch (Exception e) {
                System.err.println("AI Object Detection: Configured database connection failed: " + e.getMessage());
                System.err.println("AI Object Detection: Falling back to local SQLite database...");
            }
        }
        
        // Fallback to SQLite if primary connection fails or is not configured
        if (!connectionOk) {
            String dbPath = context.getRealPath("/WEB-INF/ai_detection.db");
            dbUrl = "jdbc:sqlite:" + dbPath;
            dbUser = "";
            dbPassword = "";
            System.out.println("AI Object Detection: Initializing SQLite database path: " + dbUrl);
        }
        
        // Initialize DBConnection config
        DBConnection.initialize(dbUrl, dbUser, dbPassword);
        
        // If SQLite, run schema initializer
        if (dbUrl.startsWith("jdbc:sqlite:")) {
            initializeDatabaseIfEmpty(dbUrl, context);
        }
    }

    private void initializeDatabaseIfEmpty(String dbUrl, ServletContext context) {
        try {
            Class.forName("org.sqlite.JDBC");
            try (Connection conn = DriverManager.getConnection(dbUrl)) {
                // Check if tables are already created
                boolean tablesExist = false;
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")) {
                    if (rs.next()) {
                        tablesExist = true;
                    }
                }
                
                if (!tablesExist) {
                    System.out.println("SQLite database is empty. Initializing schema...");
                    String schemaPath = context.getRealPath("/WEB-INF/schema.sql");
                    File schemaFile = new File(schemaPath);
                    
                    if (schemaFile.exists()) {
                        String schemaSql = new String(java.nio.file.Files.readAllBytes(schemaFile.toPath()), java.nio.charset.StandardCharsets.UTF_8);
                        
                        try (Statement stmt = conn.createStatement()) {
                            // Split and clean queries
                            String[] queries = schemaSql.split(";");
                            for (String query : queries) {
                                String cleanQuery = query.trim();
                                if (!cleanQuery.isEmpty()) {
                                    // Skip database creation statements since SQLite handles this
                                    if (cleanQuery.toUpperCase().startsWith("CREATE DATABASE") || cleanQuery.toUpperCase().startsWith("USE ")) {
                                        continue;
                                    }
                                    
                                    // Convert MySQL specific details to SQLite equivalents
                                    cleanQuery = cleanQuery
                                        .replaceAll("(?i)ENGINE\\s*=\\s*InnoDB", "")
                                        .replaceAll("(?i)DEFAULT\\s+CHARSET\\s*=\\s*\\w+", "")
                                        .replaceAll("(?i)COLLATE\\s*=\\s*\\w+", "")
                                        .replaceAll("(?i)INT\\s+AUTO_INCREMENT", "INTEGER") // SQLite auto-increment is on INTEGER primary keys
                                        .replaceAll("(?i)DOUBLE", "REAL")
                                        .replaceAll("(?i)ON\\s+DUPLICATE\\s+KEY\\s+UPDATE.*", "")
                                        .trim();
                                    
                                    if (cleanQuery.toUpperCase().startsWith("INSERT INTO ADMINS")) {
                                        cleanQuery = cleanQuery.replace("INSERT INTO admins", "INSERT OR IGNORE INTO admins");
                                    }
                                    
                                    if (!cleanQuery.isEmpty()) {
                                        System.out.println("SQLite Schema executing: " + cleanQuery);
                                        stmt.execute(cleanQuery);
                                    }
                                }
                            }
                            System.out.println("SQLite database initialized and seeded successfully.");
                        }
                    } else {
                        System.err.println("SQLite Init Error: schema.sql file not found at " + schemaPath);
                    }
                } else {
                    System.out.println("SQLite database tables already exist. Skipping schema initialization.");
                }
            }
        } catch (Exception e) {
            System.err.println("Failed to initialize SQLite schema: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup resources if needed
    }
}
