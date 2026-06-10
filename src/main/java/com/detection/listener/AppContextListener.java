package com.detection.listener;

import com.detection.conn.DBConnection;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        String dbUrl = context.getInitParameter("db.url");
        String dbUser = context.getInitParameter("db.username");
        String dbPassword = context.getInitParameter("db.password");
        
        DBConnection.initialize(dbUrl, dbUser, dbPassword);
        System.out.println("AI Object Detection: Database connection initialized successfully from context parameters.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup resources if needed
    }
}
