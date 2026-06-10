# AI Powered Object Detection System

A J2EE Dynamic Web application built on Jakarta Servlets and JSPs that performs advanced object detection on uploaded images using Python's OpenCV DNN (Deep Neural Network) module. It integrates MobileNet-SSD (Caffe) and MobileNetV2/ResNet50 (ONNX) classifiers to recognize and classify objects in real-time.

---

## Features
- **File Upload**: Supports uploading JPEG, PNG, GIF images, and MP4/AVI/MOV videos.
- **Deep Learning Model**: Combines MobileNet-SSD (Caffe framework) with ONNX classifiers (ImageNet labels) to obtain high-precision predictions.
- **Dynamic Configuration**: Supports overriding MySQL credentials and Python binary command path via environment variables.
- **Background Engine**: Servlets spawn multithreaded jobs to coordinate the Python process, parse detection results, and issue real-time status notifications.
- **Docker Support**: Completely containerized web and database services, allowing a one-click deployment.

---

## Quick Deployment (Docker Compose)
The easiest way to build, seed, and run this application is by using Docker Compose.

### Prerequisites
- [Docker](https://www.docker.com/get-started) installed on your system.

### Steps
1. Navigate to the project root directory.
2. Run the following command:
   ```bash
   docker-compose up --build
   ```
3. Docker will automatically:
   - Spin up a MySQL database container and seed it with `schema.sql` (creating tables and an admin account).
   - Set up a Tomcat container, compile Java source files, install Python, download the heavy AI models, and host the web application.
4. Once completed, access the application in your browser:
   ```
   http://localhost:8080/ai_object_detection_system
   ```

---

## Local Deployment (Manual Setup)

### Prerequisites
1. **Java Development Kit (JDK 17+)** and **Apache Tomcat 10.1+** (compatible with Jakarta EE 10 / Servlets 6.0).
2. **MySQL Server 5.7+ / 8.0+** running locally.
3. **Python 3.8+** with the package manager `pip`.

### Setup Instructions

#### 1. Setup the Database
Create the database and seed tables by executing:
```bash
mysql -u root -p < schema.sql
```
*Note: The default credentials used by the code are: DB: `ai_detection_db`, User: `root`, Password: `Root`.*

#### 2. Install Python Dependencies
Install required packages using the requirements file:
```bash
pip install -r requirements.txt
```

#### 3. Fetch AI Model Binaries
Execute the helper scripts to fetch the required neural network models:
```bash
python download_model_v2.py
python download_resnet.py
```
This downloads `MobileNetSSD_deploy.caffemodel`, `MobileNetSSD_deploy.prototxt`, `mobilenetv2-12.onnx`, and `resnet50-v2-7.onnx` into the `ai_model/` directory.

#### 4. Compile and Deploy to Tomcat
If you are on Windows, you can compile and deploy using PowerShell:
```powershell
./rebuild_and_deploy.ps1
```
Otherwise, compile manually:
1. Compile all Java files from `src/main/java` to `src/main/webapp/WEB-INF/classes`. Include your Tomcat's `servlet-api.jar` and `jsp-api.jar` in the classpath.
2. Copy the contents of `src/main/webapp/` into your Tomcat `webapps/ai_object_detection_system/` folder.
3. Copy `detect.py` and the `ai_model/` folder to the same deployed context path directory.

---

## Configuration Reference

You can customize runtime behavior by exporting the following Environment Variables before starting Tomcat/Docker:

| Variable | Description | Default Value |
|---|---|---|
| `DB_URL` | MySQL JDBC Connection URL | `jdbc:mysql://localhost:3306/ai_detection_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC` |
| `DB_USER` | MySQL Username | `root` |
| `DB_PASSWORD` | MySQL Password | `Root` |
| `PYTHON_CMD` | Binary command or absolute path to Python | `python` |

---

## Default Admin Credentials
- **Username**: `admin`
- **Password**: `admin123`
