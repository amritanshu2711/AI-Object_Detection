// =======================================================
// AI Powered Object Detection System - AJAX Features
// Uses Fetch API for live dashboard, polling, notifications
// =======================================================

/**
 * Polls the background simulation status for a running detection
 * @param {number} detectionId The ID of the detection record
 */
function startStatusPolling(detectionId) {
    const progressBar = document.getElementById("pollProgressBar");
    const progressText = document.getElementById("pollProgressText");
    const statusText = document.getElementById("pollStatusText");
    const loaderWrapper = document.getElementById("loaderWrapper");

    if (!progressBar || !progressText) return;

    const interval = setInterval(() => {
        fetch(`detection-progress?id=${detectionId}`)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    console.error("Polling error: ", data.error);
                    clearInterval(interval);
                    return;
                }

                const progress = data.progress;
                const status = data.status;

                // Update UI elements
                progressBar.style.width = `${progress}%`;
                progressText.innerText = `${progress}%`;
                
                if (statusText) {
                    statusText.innerText = `Status: ${status}...`;
                }

                if (status === "Completed") {
                    clearInterval(interval);
                    progressBar.classList.add("bg-success");
                    if (statusText) statusText.innerText = "Completed!";
                    // Wait a short moment and reload to display the canvas overlay
                    setTimeout(() => {
                        window.location.reload();
                    }, 500);
                } else if (status === "Failed") {
                    clearInterval(interval);
                    progressBar.classList.add("bg-danger");
                    if (statusText) statusText.innerText = "Processing Failed.";
                    if (loaderWrapper) {
                        loaderWrapper.innerHTML = `
                            <div class="alert alert-danger" role="alert">
                                <i class="bi bi-exclamation-triangle-fill"></i> AI Object Detection failed to execute.
                            </div>
                        `;
                    }
                }
            })
            .catch(err => {
                console.error("Fetch polling error: ", err);
                clearInterval(interval);
            });
    }, 1000);
}

/**
 * Refreshes Admin Dashboard statistics asynchronously
 */
function refreshDashboardStats() {
    const totalUsers = document.getElementById("statTotalUsers");
    const totalDetections = document.getElementById("statTotalDetections");
    const todayDetections = document.getElementById("statTodayDetections");
    const successfulDetections = document.getElementById("statSuccessfulDetections");

    if (!totalUsers) return; // Not on admin dashboard

    fetch("admin-stats")
        .then(response => response.json())
        .then(data => {
            if (data.error) return;

            // Update stats cards with micro animation transitions
            animateValue(totalUsers, parseInt(totalUsers.innerText) || 0, data.totalUsers, 1000);
            animateValue(totalDetections, parseInt(totalDetections.innerText) || 0, data.totalDetections, 1000);
            animateValue(todayDetections, parseInt(todayDetections.innerText) || 0, data.todayDetections, 1000);
            animateValue(successfulDetections, parseInt(successfulDetections.innerText) || 0, data.successfulDetections, 1000);
        })
        .catch(err => console.error("Error refreshing dashboard stats: ", err));
}

// Simple counter animation helper
function animateValue(obj, start, end, duration) {
    if (start === end) return;
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        obj.innerHTML = Math.floor(progress * (end - start) + start);
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
}

/**
 * Periodically retrieves notifications for regular user navbar dropdown
 */
function refreshNotifications(markAsRead = false) {
    const badge = document.getElementById("notificationBadge");
    const listContainer = document.getElementById("notificationList");

    if (!badge || !listContainer) return;

    const url = markAsRead ? "detection-notifications?markRead=true" : "detection-notifications";

    fetch(url)
        .then(response => response.json())
        .then(data => {
            // Update Notification Count Badge
            const count = data.unreadCount;
            if (count > 0) {
                badge.innerText = count;
                badge.classList.remove("d-none");
            } else {
                badge.classList.add("d-none");
            }

            // Fill notifications list
            const items = data.notifications;
            if (items.length === 0) {
                listContainer.innerHTML = `<div class="dropdown-item text-center text-muted py-3">No notifications</div>`;
                return;
            }

            let html = "";
            items.forEach(n => {
                const unreadClass = n.isRead ? "" : "unread";
                const dateStr = new Date(n.time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                
                html += `
                    <div class="dropdown-item notification-item ${unreadClass} d-flex flex-column gap-1">
                        <span class="text-white">${n.message}</span>
                        <small class="text-muted" style="font-size:0.75rem">${dateStr}</small>
                    </div>
                `;
            });
            
            // Add mark all read button
            if (count > 0) {
                html = `
                    <div class="d-flex justify-content-between align-items-center px-3 py-2 border-bottom border-secondary">
                        <span class="text-muted" style="font-size:0.8rem">Notifications</span>
                        <a href="javascript:void(0)" onclick="refreshNotifications(true)" class="text-primary" style="font-size:0.8rem;text-decoration:none">Mark all read</a>
                    </div>
                    ${html}
                `;
            }
            
            listContainer.innerHTML = html;
        })
        .catch(err => console.error("Error loading notifications: ", err));
}

/**
 * Searches table records without refresh
 * @param {string} inputId Input element ID
 * @param {string} tableBodyId Table body target element ID
 * @param {boolean} isAdmin Indicates search context
 */
function setupDynamicSearch(inputId, tableBodyId, isAdmin) {
    const searchInput = document.getElementById(inputId);
    const tableBody = document.getElementById(tableBodyId);

    if (!searchInput || !tableBody) return;

    searchInput.addEventListener("input", function () {
        const val = searchInput.value.trim();
        
        // Use standard search or client-side live filter depending on scope
        // If query is empty, reload standard view or fetch list. Let's do a client-side quick filter first
        // as it is extremely responsive, with an AJAX fallback.
        const rows = tableBody.getElementsByTagName("tr");
        for (let i = 0; i < rows.length; i++) {
            let rowText = rows[i].textContent.toLowerCase();
            if (rowText.includes(val.toLowerCase())) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    });
}

// Start notification and stats scheduler on load if user is logged in
document.addEventListener("DOMContentLoaded", function () {
    const isLoggedIn = document.getElementById("notificationBadge") !== null;
    if (isLoggedIn) {
        refreshNotifications();
        // Check notifications every 8 seconds
        setInterval(refreshNotifications, 8000);
    }

    const isAdminDashboard = document.getElementById("statTotalUsers") !== null;
    if (isAdminDashboard) {
        // Refresh dashboard stats every 10 seconds
        setInterval(refreshDashboardStats, 10000);
    }
});
