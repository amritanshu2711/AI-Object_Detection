// =======================================================
// AI Powered Object Detection System - Main Javascript
// Handles form validation, UI elements, and Canvas drawing
// =======================================================

document.addEventListener("DOMContentLoaded", function () {
    // Sidebar toggle control
    const menuToggle = document.getElementById("menu-toggle");
    if (menuToggle) {
        menuToggle.addEventListener("click", function (e) {
            e.preventDefault();
            const wrapper = document.getElementById("wrapper");
            if (wrapper) {
                wrapper.classList.toggle("toggled");
            }
        });
    }

    // Auto-dismiss alert notifications after 5 seconds
    const alerts = document.querySelectorAll(".alert-dismissible");
    alerts.forEach(function (alert) {
        setTimeout(function () {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
            if (bsAlert) {
                bsAlert.close();
            }
        }, 5000);
    });
});

/**
 * Validates registration form fields on client side
 */
function validateRegisterForm() {
    const fullName = document.getElementById("fullName").value.trim();
    const email = document.getElementById("email").value.trim();
    const mobileNumber = document.getElementById("mobileNumber").value.trim();
    const password = document.getElementById("password").value;
    const confirmPassword = document.getElementById("confirmPassword").value;
    const errorDiv = document.getElementById("validationErrors");

    if (errorDiv) {
        errorDiv.classList.add("d-none");
        errorDiv.innerHTML = "";
    }

    let errors = [];

    if (fullName === "" || email === "" || mobileNumber === "" || password === "") {
        errors.push("All fields are required.");
    }
    
    // Email regex validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        errors.push("Please enter a valid email address.");
    }

    // Mobile validation (simple 10 digit check)
    const mobileRegex = /^[0-9]{10,12}$/;
    if (!mobileRegex.test(mobileNumber)) {
        errors.push("Mobile number must be between 10 and 12 digits.");
    }

    if (password.length < 6) {
        errors.push("Password must be at least 6 characters long.");
    }

    if (password !== confirmPassword) {
        errors.push("Password and Confirm Password do not match.");
    }

    if (errors.length > 0) {
        if (errorDiv) {
            errorDiv.innerHTML = errors.join("<br>");
            errorDiv.classList.remove("d-none");
        }
        return false;
    }
    return true;
}

/**
 * Draws simulated bounding boxes on HTML5 Canvas over uploaded image
 * @param {string} canvasId Canvas element ID
 * @param {string} imgId Image element ID
 * @param {Array} results Array containing detection coordinate maps
 */
function drawBoundingBoxes(canvasId, imgId, results) {
    const canvas = document.getElementById(canvasId);
    const img = document.getElementById(imgId);
    
    if (!canvas || !img) {
        return;
    }

    // Set canvas dimensions to match the layout client sizing of the image
    const updateCanvasSize = () => {
        canvas.width = img.clientWidth;
        canvas.height = img.clientHeight;
        
        const ctx = canvas.getContext('2d');
        if (!ctx) return;
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        // Map resolution coordinate space (simulated model outputs relative to 640x480 resolution)
        const scaleX = canvas.width / 640;
        const scaleY = canvas.height / 480;

        results.forEach((box, index) => {
            const x = box.boxX * scaleX;
            const y = box.boxY * scaleY;
            const w = box.boxWidth * scaleX;
            const h = box.boxHeight * scaleY;

            // Use alternating bright colors for bounding box highlights
            const colors = ['#6366f1', '#10b981', '#3b82f6', '#f59e0b', '#ec4899'];
            const color = colors[index % colors.length];

            // 1. Draw box rectangle
            ctx.strokeStyle = color;
            ctx.lineWidth = 3;
            ctx.shadowBlur = 10;
            ctx.shadowColor = color;
            ctx.strokeRect(x, y, w, h);
            
            // Reset shadow for text drawing
            ctx.shadowBlur = 0;

            // 2. Draw label banner background
            ctx.fillStyle = color;
            const label = box.objectName + " (" + Math.round(box.confidenceScore * 100) + "%)";
            ctx.font = 'bold 12px Outfit, sans-serif';
            const textMetrics = ctx.measureText(label);
            const bannerWidth = textMetrics.width + 12;
            const bannerHeight = 22;

            // Draw label slightly inside the box or directly on top
            let labelY = y - bannerHeight;
            if (labelY < 0) {
                labelY = y; // Draw inside box top if it overflows canvas boundary
            }
            
            ctx.fillRect(x, labelY, bannerWidth, bannerHeight);

            // 3. Draw text label string
            ctx.fillStyle = '#ffffff';
            ctx.fillText(label, x + 6, labelY + 15);
        });
    };

    // Draw immediately or when image has fully loaded
    if (img.complete) {
        updateCanvasSize();
    } else {
        img.onload = updateCanvasSize;
    }

    // Re-draw when window resizes to ensure responsive bounding boxes match image location
    window.addEventListener('resize', updateCanvasSize);
}
