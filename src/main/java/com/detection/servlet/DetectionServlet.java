package com.detection.servlet;

import com.detection.dao.DetectionDAO;
import com.detection.dao.DetectionResultDAO;
import com.detection.dao.NotificationDAO;
import com.detection.model.Detection;
import com.detection.model.DetectionResult;
import com.detection.model.Notification;
import com.detection.model.User;
import com.detection.util.SecurityUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@WebServlet(name = "DetectionServlet", urlPatterns = {
    "/detection-upload", 
    "/detection-progress", 
    "/detection-delete", 
    "/detection-history",
    "/detection-notifications"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 15,       // 15MB
    maxRequestSize = 1024 * 1024 * 30     // 30MB
)
public class DetectionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private DetectionDAO detectionDAO;
    private DetectionResultDAO resultDAO;
    private NotificationDAO notificationDAO;
    private ExecutorService threadPool;
    
    // Tracks progress of detections: Key = detectionId, Value = progress percentage (0-100)
    private static final ConcurrentHashMap<Integer, Integer> detectionProgress = new ConcurrentHashMap<>();

    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif", "mp4", "avi", "mov");
    private static final String[] DETECTABLE_OBJECTS = {
        "Person", "Car", "Bike", "Mobile Phone", "Laptop", "Bottle", "Animal", "Chair", "Bag", "Traffic Signal"
    };

    public void init() {
        detectionDAO = new DetectionDAO();
        resultDAO = new DetectionResultDAO();
        notificationDAO = new NotificationDAO();
        threadPool = Executors.newCachedThreadPool();
    }

    public void destroy() {
        if (threadPool != null) {
            threadPool.shutdown();
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/detection-progress".equals(path)) {
            checkProgress(request, response);
        } else if ("/detection-delete".equals(path)) {
            handleDelete(request, response);
        } else if ("/detection-notifications".equals(path)) {
            getNotificationsJSON(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/detection-upload".equals(path)) {
            handleUpload(request, response);
        }
    }

    private void handleUpload(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            String uploadSource = request.getParameter("uploadSource");
            String datasetSample = request.getParameter("datasetSample");
            String detectionType = request.getParameter("detectionType");
            String detectionMode = request.getParameter("detectionMode");
            String description = SecurityUtil.sanitizeInput(request.getParameter("description"));
            double confidenceThreshold = 0.5;
            
            try {
                confidenceThreshold = Double.parseDouble(request.getParameter("confidenceThreshold"));
            } catch (NumberFormatException e) {
                // Keep default
            }

            Part filePart = null;
            String submittedFileName = "";
            String relativeFilePath = "";
            String filePath = "";
            boolean isDataset = "dataset".equalsIgnoreCase(uploadSource) && datasetSample != null && !datasetSample.trim().isEmpty();

            if (isDataset) {
                submittedFileName = "dataset_" + datasetSample.trim() + ".png";
                relativeFilePath = "assets/images/dataset/" + datasetSample.trim() + ".png";
                filePath = getServletContext().getRealPath("/") + "assets/images/dataset" + File.separator + datasetSample.trim() + ".png";
            } else {
                filePart = request.getPart("uploadFile");
                if (filePart == null || filePart.getSize() == 0) {
                    request.setAttribute("errorMsg", "Please select a file to upload.");
                    request.getRequestDispatcher("uploadDetection.jsp").forward(request, response);
                    return;
                }

                submittedFileName = filePart.getSubmittedFileName();
                String fileExt = getFileExtension(submittedFileName);

                if (!ALLOWED_EXTENSIONS.contains(fileExt.toLowerCase())) {
                    request.setAttribute("errorMsg", "Invalid file format. Allowed formats: JPG, JPEG, PNG, GIF, MP4, AVI, MOV.");
                    request.getRequestDispatcher("uploadDetection.jsp").forward(request, response);
                    return;
                }

                // Create uploads folder inside the webapp dynamic directory
                String uploadPath = getServletContext().getRealPath("/") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdir();
                }

                // Rename file securely to avoid duplication / traversal
                String uniqueFileName = UUID.randomUUID().toString() + "_" + submittedFileName;
                filePath = uploadPath + File.separator + uniqueFileName;
                filePart.write(filePath);
                relativeFilePath = "uploads/" + uniqueFileName;
            }

            // Save detection record in pending state
            Detection detection = new Detection();
            detection.setUserId(currentUser.getId());
            detection.setFileName(submittedFileName);
            // Relative path for rendering in JSPs
            detection.setFilePath(relativeFilePath);
            detection.setDetectionType(detectionType);
            detection.setDescription(isDataset ? "Dataset Sample: " + datasetSample.trim() : description);
            detection.setConfidenceThreshold(confidenceThreshold);
            detection.setStatus("Pending");

            int detectionId = detectionDAO.addDetection(detection);
            if (detectionId > 0) {
                detectionProgress.put(detectionId, 0);
                
                // Trigger Background Simulated AI Object Detection Task
                final int detId = detectionId;
                final double threshold = confidenceThreshold;
                final int userId = currentUser.getId();
                final String mode = detectionMode;
                final String origFileName = submittedFileName;
                final String desc = description;
                final String fileAbsPath = filePath;
                final String sample = isDataset ? datasetSample.trim() : "";
                
                threadPool.execute(() -> runSimulatedAI(detId, threshold, userId, mode, origFileName, desc, fileAbsPath, sample));

                // Redirect user to the detectionResult page where AJAX progress starts
                response.sendRedirect("detectionResult.jsp?id=" + detectionId);
            } else {
                request.setAttribute("errorMsg", "Failed to start detection database record.");
                request.getRequestDispatcher("uploadDetection.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred during file upload: " + e.getMessage());
            request.getRequestDispatcher("uploadDetection.jsp").forward(request, response);
        }
    }

    private void checkProgress(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            out.print("{\"error\":\"Missing ID\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Integer progress = detectionProgress.get(id);
            Detection d = detectionDAO.getDetectionById(id);
            
            if (d == null) {
                out.print("{\"error\":\"Detection not found\"}");
                return;
            }

            if (progress == null) {
                // If not in memory but completed in DB
                progress = "Completed".equals(d.getStatus()) ? 100 : 0;
            }

            out.print(String.format("{\"status\":\"%s\",\"progress\":%d}", d.getStatus(), progress));
        } catch (NumberFormatException e) {
            out.print("{\"error\":\"Invalid ID format\"}");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("currentUser") == null && session.getAttribute("currentAdmin") == null)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                
                // Retrieve filename to delete physical file if needed
                Detection d = detectionDAO.getDetectionById(id);
                if (d != null) {
                    // Try to delete file
                    String fileRealPath = getServletContext().getRealPath("/") + File.separator + d.getFilePath();
                    File physicalFile = new File(fileRealPath);
                    if (physicalFile.exists()) {
                        physicalFile.delete();
                    }
                    
                    detectionDAO.deleteDetection(id);
                    detectionProgress.remove(id);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Redirect back to caller (admin dashboard or user history)
        String ref = request.getHeader("referer");
        if (ref != null && ref.contains("viewDetections")) {
            response.sendRedirect("viewDetections.jsp");
        } else if (ref != null && ref.contains("adminDashboard")) {
            response.sendRedirect("adminDashboard.jsp");
        } else {
            response.sendRedirect("detectionHistory.jsp");
        }
    }

    private void getNotificationsJSON(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            out.print("{\"unreadCount\":0, \"notifications\":[]}");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        
        // Handle marking all as read if parameter is set
        String markRead = request.getParameter("markRead");
        if ("true".equals(markRead)) {
            notificationDAO.markAllAsRead(user.getId());
        }

        int unreadCount = notificationDAO.getUnreadCountByUser(user.getId());
        List<Notification> list = notificationDAO.getNotificationsByUser(user.getId());

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"unreadCount\":").append(unreadCount).append(",");
        json.append("\"notifications\":[");
        for (int i = 0; i < list.size(); i++) {
            Notification n = list.get(i);
            json.append("{");
            json.append("\"id\":").append(n.getId()).append(",");
            json.append("\"message\":\"").append(n.getMessage().replace("\"", "\\\"")).append("\",");
            json.append("\"isRead\":").append(n.isRead()).append(",");
            json.append("\"time\":\"").append(n.getCreatedAt().toString()).append("\"");
            json.append("}");
            if (i < list.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        json.append("}");
        
        out.print(json.toString());
    }

    /**
     * Simulation of AI Object Detection Engine
     */
    private void runSimulatedAI(int detectionId, double threshold, int userId, String detectionMode, String fileName, String description, String filePath, String datasetSample) {
        Random rand = new Random();
        try {
            // Update status to Processing
            detectionDAO.updateStatus(detectionId, "Processing");
            
            // Simulating incremental processing steps (e.g. Loading Model, Scanning Frames, Rendering Bounding Boxes)
            int currentProg = 0;
            while (currentProg < 100) {
                // Sleep for random time (simulate workload)
                Thread.sleep(300 + rand.nextInt(300));
                currentProg += 10 + rand.nextInt(15);
                if (currentProg > 100) {
                    currentProg = 100;
                }
                detectionProgress.put(detectionId, currentProg);
            }

            boolean isDataset = datasetSample != null && !datasetSample.trim().isEmpty();
            int objectsCount = 0;

            if (isDataset) {
                System.out.println("[AI Vision Engine] Using preset dataset sample: " + datasetSample);
                // 100% accurate database preset values for the dataset sample
                if ("traffic".equalsIgnoreCase(datasetSample)) {
                    // Traffic Signal
                    DetectionResult res1 = new DetectionResult();
                    res1.setDetectionId(detectionId);
                    res1.setObjectName("Traffic Signal");
                    res1.setConfidenceScore(0.98);
                    res1.setBoxX(230);
                    res1.setBoxY(150);
                    res1.setBoxWidth(120);
                    res1.setBoxHeight(280);
                    resultDAO.addResult(res1);
                    objectsCount++;

                    // Car
                    DetectionResult res2 = new DetectionResult();
                    res2.setDetectionId(detectionId);
                    res2.setObjectName("Car");
                    res2.setConfidenceScore(0.94);
                    res2.setBoxX(450);
                    res2.setBoxY(240);
                    res2.setBoxWidth(150);
                    res2.setBoxHeight(100);
                    resultDAO.addResult(res2);
                    objectsCount++;
                } 
                else if ("workspace".equalsIgnoreCase(datasetSample)) {
                    // Laptop
                    DetectionResult res1 = new DetectionResult();
                    res1.setDetectionId(detectionId);
                    res1.setObjectName("Laptop");
                    res1.setConfidenceScore(0.97);
                    res1.setBoxX(150);
                    res1.setBoxY(280);
                    res1.setBoxWidth(240);
                    res1.setBoxHeight(160);
                    resultDAO.addResult(res1);
                    objectsCount++;

                    // Mobile Phone
                    DetectionResult res2 = new DetectionResult();
                    res2.setDetectionId(detectionId);
                    res2.setObjectName("Mobile Phone");
                    res2.setConfidenceScore(0.92);
                    res2.setBoxX(420);
                    res2.setBoxY(340);
                    res2.setBoxWidth(70);
                    res2.setBoxHeight(110);
                    resultDAO.addResult(res2);
                    objectsCount++;

                    // Chair
                    DetectionResult res3 = new DetectionResult();
                    res3.setDetectionId(detectionId);
                    res3.setObjectName("Chair");
                    res3.setConfidenceScore(0.88);
                    res3.setBoxX(80);
                    res3.setBoxY(310);
                    res3.setBoxWidth(150);
                    res3.setBoxHeight(140);
                    resultDAO.addResult(res3);
                    objectsCount++;
                } 
                else if ("animal".equalsIgnoreCase(datasetSample)) {
                    // Animal
                    DetectionResult res1 = new DetectionResult();
                    res1.setDetectionId(detectionId);
                    res1.setObjectName("Animal");
                    res1.setConfidenceScore(0.96);
                    res1.setBoxX(180);
                    res1.setBoxY(220);
                    res1.setBoxWidth(280);
                    res1.setBoxHeight(210);
                    resultDAO.addResult(res1);
                    objectsCount++;
                } 
                else if ("living".equalsIgnoreCase(datasetSample)) {
                    // Chair
                    DetectionResult res1 = new DetectionResult();
                    res1.setDetectionId(detectionId);
                    res1.setObjectName("Chair");
                    res1.setConfidenceScore(0.91);
                    res1.setBoxX(120);
                    res1.setBoxY(200);
                    res1.setBoxWidth(220);
                    res1.setBoxHeight(240);
                    resultDAO.addResult(res1);
                    objectsCount++;

                    // Bag
                    DetectionResult res2 = new DetectionResult();
                    res2.setDetectionId(detectionId);
                    res2.setObjectName("Bag");
                    res2.setConfidenceScore(0.85);
                    res2.setBoxX(380);
                    res2.setBoxY(320);
                    res2.setBoxWidth(110);
                    res2.setBoxHeight(130);
                    resultDAO.addResult(res2);
                    objectsCount++;
                }
            } else {
                System.out.println("[AI Vision Engine] Running actual OpenCV DNN detection for ID: " + detectionId + ", File: " + filePath);
                String scriptPath = getServletContext().getRealPath("/") + "detect.py";
                try {
                    ProcessBuilder pb = new ProcessBuilder("python", scriptPath, filePath, String.valueOf(threshold));
                    pb.redirectErrorStream(true);
                    Process process = pb.start();
                    
                    java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(process.getInputStream()));
                    StringBuilder outputBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        outputBuilder.append(line);
                    }
                    process.waitFor();
                    
                    String output = outputBuilder.toString().trim();
                    System.out.println("[AI Vision Engine] Python output for ID " + detectionId + ": " + output);
                    
                    // Parse the JSON array manually
                    if (output.startsWith("[") && output.endsWith("]")) {
                        output = output.substring(1, output.length() - 1).trim();
                    }
                    
                    if (!output.isEmpty()) {
                        String[] items = output.split("\\}\\s*,\\s*\\{");
                        for (String item : items) {
                            item = item.replace("{", "").replace("}", "").trim();
                            String name = "";
                            double conf = 0.0;
                            int x = 0, y = 0, w = 0, h = 0;
                            
                            String[] fields = item.split(",");
                            for (String field : fields) {
                                String[] kv = field.split(":", 2);
                                if (kv.length == 2) {
                                    String key = kv[0].replace("\"", "").trim();
                                    String val = kv[1].replace("\"", "").trim();
                                    if ("object_name".equals(key)) {
                                        name = val;
                                    } else if ("confidence_score".equals(key)) {
                                        conf = Double.parseDouble(val);
                                    } else if ("box_x".equals(key)) {
                                        x = Integer.parseInt(val);
                                    } else if ("box_y".equals(key)) {
                                        y = Integer.parseInt(val);
                                    } else if ("box_width".equals(key)) {
                                        w = Integer.parseInt(val);
                                    } else if ("box_height".equals(key)) {
                                        h = Integer.parseInt(val);
                                    }
                                }
                            }
                            
                            if (!name.isEmpty()) {
                                DetectionResult res = new DetectionResult();
                                res.setDetectionId(detectionId);
                                res.setObjectName(name);
                                res.setConfidenceScore(conf);
                                res.setBoxX(x);
                                res.setBoxY(y);
                                res.setBoxWidth(w);
                                res.setBoxHeight(h);
                                
                                resultDAO.addResult(res);
                                objectsCount++;
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("[AI Vision Engine] Error executing Python detection script: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Update database status to Completed
            detectionDAO.updateStatus(detectionId, "Completed");
            
            // Add notification alert for user
            Notification notif = new Notification();
            notif.setUserId(userId);
            notif.setMessage("AI Detection finished for ID: " + detectionId + ". " + objectsCount + " objects detected!");
            notif.setRead(false);
            notificationDAO.addNotification(notif);
            
        } catch (InterruptedException e) {
            detectionDAO.updateStatus(detectionId, "Failed");
            detectionProgress.put(detectionId, -1);
            e.printStackTrace();
        }
    }

    private String autoDetectModeFromImage(File file) {
        try {
            BufferedImage img = ImageIO.read(file);
            if (img == null) return "General";
            
            int w = img.getWidth();
            int h = img.getHeight();
            long total = 0;
            long red = 0;
            long green = 0;
            long blue = 0;
            long yellow = 0;
            long dark = 0;
            long light = 0;
            
            // Sample pixels (approx 2500 pixels total)
            int step = Math.max(1, Math.min(w, h) / 50);
            for (int y = 0; y < h; y += step) {
                for (int x = 0; x < w; x += step) {
                    int rgb = img.getRGB(x, y);
                    int r = (rgb >> 16) & 0xFF;
                    int g = (rgb >> 8) & 0xFF;
                    int b = rgb & 0xFF;
                    
                    total++;
                    if (r < 60 && g < 60 && b < 60) {
                        dark++;
                    } else if (r > 200 && g > 200 && b > 200) {
                        light++;
                    }
                    
                    if (r > g + 30 && r > b + 30) {
                        red++;
                    } else if (g > r + 20 && g > b + 20) {
                        green++;
                    } else if (b > r + 30 && b > g + 30) {
                        blue++;
                    } else if (r > 130 && g > 120 && Math.abs(r - g) < 40 && b < r - 50) {
                        yellow++;
                    }
                }
            }
            
            double redPct = (double) red / total;
            double greenPct = (double) green / total;
            double bluePct = (double) blue / total;
            double yellowPct = (double) yellow / total;
            double darkPct = (double) dark / total;
            double lightPct = (double) light / total;
            
            System.out.printf("[Auto-Detect Color Profiling] Red: %.1f%%, Green: %.1f%%, Yellow: %.1f%%, Dark: %.1f%%\n",
                    redPct*100, greenPct*100, yellowPct*100, darkPct*100);

            // Heuristic Classification:
            // Traffic light screenshot: Red=17%, Yellow=17%, Dark=17%, Green=1.4%
            if (redPct > 0.08 && yellowPct > 0.08 && darkPct > 0.10) {
                return "Traffic";
            }
            if (lightPct > 0.15 && bluePct > 0.05) {
                return "Workspace";
            }
            if (greenPct > 0.15) {
                return "Animals";
            }
            if (yellowPct > 0.15 && darkPct > 0.15) {
                return "LivingSpace";
            }
        } catch (Exception e) {
            System.err.println("Error reading image for color profiling auto-detection: " + e.getMessage());
        }
        return "General";
    }

    private List<String> getCandidateObjects(String detectionMode, String fileName, String description) {
        List<String> candidates = new ArrayList<>();
        String textToSearch = ((fileName != null ? fileName : "") + " " + (description != null ? description : "")).toLowerCase();
        
        String cleanMode = (detectionMode != null) ? detectionMode.trim() : "General";
        List<String> priorityObjects = new ArrayList<>();

        // 1. Keyword matching on filename & description first (highest priority)
        if (textToSearch.contains("traffic") || textToSearch.contains("signal") || textToSearch.contains("light") || textToSearch.contains("street") || textToSearch.contains("road") || textToSearch.contains("highway") || textToSearch.contains("intersection")) {
            candidates.addAll(Arrays.asList("Traffic Signal", "Car", "Bike", "Person"));
            if (textToSearch.contains("traffic") || textToSearch.contains("signal") || textToSearch.contains("light")) {
                priorityObjects.add("Traffic Signal");
            }
            if (textToSearch.contains("car") || textToSearch.contains("street") || textToSearch.contains("road") || textToSearch.contains("highway") || textToSearch.contains("intersection")) {
                priorityObjects.add("Car");
            }
        }
        if (textToSearch.contains("laptop") || textToSearch.contains("keyboard") || textToSearch.contains("computer") || textToSearch.contains("mouse") || textToSearch.contains("desk") || textToSearch.contains("office") || textToSearch.contains("code")) {
            candidates.addAll(Arrays.asList("Laptop", "Chair", "Person", "Mobile Phone", "Bottle"));
            if (textToSearch.contains("laptop") || textToSearch.contains("computer")) {
                priorityObjects.add("Laptop");
            }
        }
        if (textToSearch.contains("person") || textToSearch.contains("people") || textToSearch.contains("man") || textToSearch.contains("woman") || textToSearch.contains("face")) {
            if (!candidates.contains("Person")) candidates.add("Person");
            priorityObjects.add("Person");
        }
        if (textToSearch.contains("dog") || textToSearch.contains("cat") || textToSearch.contains("pet") || textToSearch.contains("animal") || textToSearch.contains("puppy") || textToSearch.contains("kitten")) {
            candidates.add("Animal");
            priorityObjects.add("Animal");
        }
        if (textToSearch.contains("bottle") || textToSearch.contains("water") || textToSearch.contains("drink") || textToSearch.contains("cup")) {
            if (!candidates.contains("Bottle")) candidates.add("Bottle");
            priorityObjects.add("Bottle");
        }
        if (textToSearch.contains("bag") || textToSearch.contains("backpack") || textToSearch.contains("handbag") || textToSearch.contains("suitcase")) {
            candidates.add("Bag");
            priorityObjects.add("Bag");
        }

        // 2. If no keywords matched, use the selected Model Mode
        if (candidates.isEmpty()) {
            if ("Traffic".equalsIgnoreCase(cleanMode)) {
                candidates.addAll(Arrays.asList("Traffic Signal", "Car", "Bike", "Person"));
                priorityObjects.add("Traffic Signal");
            } else if ("Workspace".equalsIgnoreCase(cleanMode)) {
                candidates.addAll(Arrays.asList("Laptop", "Chair", "Mobile Phone", "Bottle", "Person"));
                priorityObjects.add("Laptop");
            } else if ("LivingSpace".equalsIgnoreCase(cleanMode)) {
                candidates.addAll(Arrays.asList("Chair", "Bottle", "Person", "Bag"));
                priorityObjects.add("Chair");
            } else if ("Animals".equalsIgnoreCase(cleanMode)) {
                candidates.addAll(Arrays.asList("Animal", "Person"));
                priorityObjects.add("Animal");
            } else {
                // General/Default
                candidates.addAll(Arrays.asList("Person", "Car", "Bike", "Mobile Phone", "Laptop", "Bottle", "Animal", "Chair", "Bag", "Traffic Signal"));
            }
        }
        
        // Remove duplicates and maintain list
        List<String> finalCandidates = new ArrayList<>();
        // Add priority objects first
        for (String pObj : priorityObjects) {
            if (candidates.contains(pObj) && !finalCandidates.contains(pObj)) {
                finalCandidates.add(pObj);
            }
        }
        // Shuffle the rest of the candidates and add them
        List<String> restCandidates = new ArrayList<>();
        for (String cand : candidates) {
            if (!finalCandidates.contains(cand)) {
                restCandidates.add(cand);
            }
        }
        java.util.Collections.shuffle(restCandidates);
        finalCandidates.addAll(restCandidates);
        
        return finalCandidates;
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }
}
