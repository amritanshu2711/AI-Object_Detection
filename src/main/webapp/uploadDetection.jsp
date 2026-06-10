<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.detection.model.User" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Detection Scan - AI Vision Engine</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom Style -->
    <link href="assets/css/style.css?v=2.0" rel="stylesheet">
    <style>
        .dataset-card:hover {
            transform: translateY(-3px);
            border-color: #0d6efd !important;
            box-shadow: 0 4px 15px rgba(13, 110, 253, 0.2);
        }
        .dataset-card.selected {
            border-color: #0d6efd !important;
            background: rgba(13, 110, 253, 0.1) !important;
            box-shadow: 0 4px 20px rgba(13, 110, 253, 0.4);
        }
        .nav-pills .nav-link.active {
            background-color: #0d6efd !important;
        }
    </style>
</head>
<body>

    <div class="d-flex" id="wrapper">
        <!-- Sidebar -->
        <%@ include file="includes/sidebar.jsp" %>

        <!-- Page Content -->
        <div id="page-content-wrapper">
            <!-- Navbar -->
            <%@ include file="includes/navbar.jsp" %>

            <div class="container-fluid px-4 py-4">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="glass-card p-4 p-md-5">
                            <div class="text-center mb-4">
                                <i class="bi bi-cloud-arrow-up-fill text-primary fs-1"></i>
                                <h3 class="fw-bold text-white mt-2">New Object Detection Scan</h3>
                                <p class="text-muted small">Upload an image or video file and select your desired options</p>
                            </div>

                            <% 
                                String errorMsg = (String) request.getAttribute("errorMsg");
                                if (errorMsg != null) { 
                            %>
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="bi bi-exclamation-triangle-fill"></i> <%= errorMsg %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            <% } %>

                            <form action="detection-upload" method="POST" enctype="multipart/form-data" id="uploadForm">
                                <!-- Input Source Selection Tabs -->
                                <ul class="nav nav-pills nav-fill mb-4 p-1 glass-card" style="border-radius: 12px; background: rgba(255,255,255,0.05);" id="sourceTabs" role="tablist">
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link active fw-semibold text-white py-2" id="file-tab" data-bs-toggle="pill" data-bs-target="#file-upload-pane" type="button" role="tab" onclick="setUploadSource('file')"><i class="bi bi-file-earmark-arrow-up"></i> Upload Custom File</button>
                                    </li>
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link fw-semibold text-white py-2" id="dataset-tab" data-bs-toggle="pill" data-bs-target="#dataset-pane" type="button" role="tab" onclick="setUploadSource('dataset')"><i class="bi bi-database-fill"></i> Select from Dataset</button>
                                    </li>
                                </ul>

                                <input type="hidden" name="uploadSource" id="uploadSource" value="file">
                                <input type="hidden" name="datasetSample" id="datasetSample" value="">

                                <div class="tab-content">
                                    <!-- Tab 1: File Upload Pane -->
                                    <div class="tab-pane fade show active" id="file-upload-pane" role="tabpanel">
                                        <!-- File Upload Dropzone -->
                                        <div class="mb-4">
                                            <label for="uploadFile" class="form-label text-muted small">Select Image/Video File</label>
                                            <input type="file" class="form-control" id="uploadFile" name="uploadFile" accept="image/*,video/*" required>
                                            <div class="form-text text-muted small">Supported extensions: JPG, JPEG, PNG, GIF, MP4, AVI, MOV. Max size: 15MB.</div>
                                        </div>
                                    </div>

                                    <!-- Tab 2: Sample Dataset Pane -->
                                    <div class="tab-pane fade" id="dataset-pane" role="tabpanel">
                                        <div class="mb-4">
                                            <label class="form-label text-muted small d-block mb-3">Choose a Demo Dataset Image</label>
                                            <div class="row g-3">
                                                <!-- Card 1: Traffic -->
                                                <div class="col-sm-6">
                                                    <div class="card dataset-card h-100 bg-transparent text-white border-secondary-subtle" onclick="selectDataset('traffic', this)" style="cursor: pointer; border-radius: 12px; transition: all 0.3s ease; border: 1px solid rgba(255,255,255,0.1); background: rgba(255,255,255,0.02) !important;">
                                                        <div class="position-relative overflow-hidden" style="height: 120px; border-radius: 11px 11px 0 0;">
                                                            <img src="assets/images/dataset/traffic.png" class="w-100 h-100 object-fit-cover" alt="Traffic & Street Scene">
                                                        </div>
                                                        <div class="card-body p-3">
                                                            <h6 class="fw-bold mb-1" style="font-size: 0.9rem;"><i class="bi bi-car-front-fill text-primary"></i> Traffic Signal</h6>
                                                            <p class="text-muted small mb-0" style="font-size: 0.75rem;">Detects: Traffic Signal, Car, Bike, Person</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Card 2: Workspace -->
                                                <div class="col-sm-6">
                                                    <div class="card dataset-card h-100 bg-transparent text-white border-secondary-subtle" onclick="selectDataset('workspace', this)" style="cursor: pointer; border-radius: 12px; transition: all 0.3s ease; border: 1px solid rgba(255,255,255,0.1); background: rgba(255,255,255,0.02) !important;">
                                                        <div class="position-relative overflow-hidden" style="height: 120px; border-radius: 11px 11px 0 0;">
                                                            <img src="assets/images/dataset/workspace.png" class="w-100 h-100 object-fit-cover" alt="Office & Workspace">
                                                        </div>
                                                        <div class="card-body p-3">
                                                            <h6 class="fw-bold mb-1" style="font-size: 0.9rem;"><i class="bi bi-laptop-fill text-primary"></i> Office Workspace</h6>
                                                            <p class="text-muted small mb-0" style="font-size: 0.75rem;">Detects: Laptop, Chair, Phone, Bottle</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Card 3: Animals -->
                                                <div class="col-sm-6">
                                                    <div class="card dataset-card h-100 bg-transparent text-white border-secondary-subtle" onclick="selectDataset('animal', this)" style="cursor: pointer; border-radius: 12px; transition: all 0.3s ease; border: 1px solid rgba(255,255,255,0.1); background: rgba(255,255,255,0.02) !important;">
                                                        <div class="position-relative overflow-hidden" style="height: 120px; border-radius: 11px 11px 0 0;">
                                                            <img src="assets/images/dataset/animal.png" class="w-100 h-100 object-fit-cover" alt="Animals & Pets">
                                                        </div>
                                                        <div class="card-body p-3">
                                                            <h6 class="fw-bold mb-1" style="font-size: 0.9rem;"><i class="bi bi-dog text-primary"></i> Animals & Pets</h6>
                                                            <p class="text-muted small mb-0" style="font-size: 0.75rem;">Detects: Dog (Animal), Person</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Card 4: LivingSpace -->
                                                <div class="col-sm-6">
                                                    <div class="card dataset-card h-100 bg-transparent text-white border-secondary-subtle" onclick="selectDataset('living', this)" style="cursor: pointer; border-radius: 12px; transition: all 0.3s ease; border: 1px solid rgba(255,255,255,0.1); background: rgba(255,255,255,0.02) !important;">
                                                        <div class="position-relative overflow-hidden" style="height: 120px; border-radius: 11px 11px 0 0;">
                                                            <img src="assets/images/dataset/living.png" class="w-100 h-100 object-fit-cover" alt="Cozy Living Space">
                                                        </div>
                                                        <div class="card-body p-3">
                                                            <h6 class="fw-bold mb-1" style="font-size: 0.9rem;"><i class="bi bi-house-fill text-primary"></i> Cozy Living Space</h6>
                                                            <p class="text-muted small mb-0" style="font-size: 0.75rem;">Detects: Lounge Chair, Bag</p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <!-- Detection Type -->
                                    <div class="col-lg-4 col-md-6 mb-3">
                                        <label for="detectionType" class="form-label text-muted small">Detection Target Type</label>
                                        <select class="form-select" id="detectionType" name="detectionType" required>
                                            <option value="Image">Image Scanning</option>
                                            <option value="Video">Video Tracking</option>
                                        </select>
                                    </div>

                                    <!-- AI Model Mode -->
                                    <div class="col-lg-4 col-md-6 mb-3">
                                        <label for="detectionMode" class="form-label text-muted small">AI Model Scanning Mode</label>
                                        <select class="form-select" id="detectionMode" name="detectionMode" required>
                                            <option value="General">General / Auto-Detect</option>
                                            <option value="Traffic">Traffic & Street Scene</option>
                                            <option value="Workspace">Office & Electronics</option>
                                            <option value="LivingSpace">Indoor & Furniture</option>
                                            <option value="Animals">Animals & Pets</option>
                                        </select>
                                    </div>

                                    <!-- Confidence Threshold -->
                                    <div class="col-lg-4 col-md-12 mb-3">
                                        <label for="confidenceThreshold" class="form-label text-muted small">Confidence Threshold</label>
                                        <div class="d-flex align-items-center gap-3">
                                            <input type="range" class="form-range" id="confidenceThreshold" name="confidenceThreshold" min="0.10" max="0.95" step="0.05" value="0.50" oninput="document.getElementById('thresholdVal').innerText = Math.round(this.value * 100) + '%'">
                                            <span id="thresholdVal" class="badge bg-primary p-2">50%</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Description -->
                                <div class="mb-4">
                                    <label for="description" class="form-label text-muted small">File Description / Notes (Optional)</label>
                                    <textarea class="form-control" id="description" name="description" rows="3" placeholder="Add some context or labels to look for..."></textarea>
                                </div>

                                <!-- Loading / Action Area -->
                                <div id="submitBtnArea">
                                    <button type="submit" class="btn btn-primary w-100 py-3 fw-bold fs-6"><i class="bi bi-cpu-fill"></i> Initiate Object Detection</button>
                                </div>
                                <div id="loadingArea" class="d-none text-center py-3">
                                    <div class="spinner-border text-primary mb-3" role="status" style="width: 3rem; height: 3rem;">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                    <h5 class="fw-bold text-white mb-1">Uploading and Initializing Engine</h5>
                                    <p class="text-muted small">Please do not refresh or navigate away from the page.</p>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>
    
    <script>
        function setUploadSource(source) {
            document.getElementById('uploadSource').value = source;
            var fileInput = document.getElementById('uploadFile');
            if (source === 'file') {
                fileInput.setAttribute('required', 'required');
            } else {
                fileInput.removeAttribute('required');
            }
        }

        function selectDataset(sampleId, cardElement) {
            document.getElementById('datasetSample').value = sampleId;
            var cards = document.querySelectorAll('.dataset-card');
            cards.forEach(function(card) {
                card.classList.remove('selected');
            });
            cardElement.classList.add('selected');
            
            var modeSelect = document.getElementById('detectionMode');
            if (sampleId === 'traffic') {
                modeSelect.value = 'Traffic';
            } else if (sampleId === 'workspace') {
                modeSelect.value = 'Workspace';
            } else if (sampleId === 'animal') {
                modeSelect.value = 'Animals';
            } else if (sampleId === 'living') {
                modeSelect.value = 'LivingSpace';
            }
        }

        document.getElementById("uploadForm").addEventListener("submit", function(event) {
            if (document.getElementById('uploadSource').value === 'dataset') {
                var sample = document.getElementById('datasetSample').value;
                if (!sample) {
                    alert('Please select a dataset image to proceed!');
                    event.preventDefault();
                    return;
                }
            }
            // Hide submit button and show custom loader animation during upload
            document.getElementById("submitBtnArea").classList.add("d-none");
            document.getElementById("loadingArea").classList.remove("d-none");
        });
    </script>

</body>
</html>
