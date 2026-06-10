# ==========================================
# Stage 1: Build Java Sources
# ==========================================
FROM tomcat:10.1-jdk17-slim AS builder

WORKDIR /build

# Copy source directory
COPY src ./src

# Create output classes directory
RUN mkdir -p src/main/webapp/WEB-INF/classes

# Compile Java files using Tomcat standard libraries in classpath
RUN javac -d src/main/webapp/WEB-INF/classes \
    -classpath "/usr/local/tomcat/lib/servlet-api.jar:/usr/local/tomcat/lib/jsp-api.jar:src/main/webapp/WEB-INF/lib/*" \
    $(find src/main/java -name "*.java")

# ==========================================
# Stage 2: Final Runtime Image
# ==========================================
FROM tomcat:10.1-jdk17-slim

# Install Python 3, pip, and compilation utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python requirements
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# Set deployment folder inside Tomcat
WORKDIR /usr/local/tomcat/webapps/ai_object_detection_system

# Copy compiled classes and web resources from builder
COPY --from=builder /build/src/main/webapp ./

# Copy Python detection scripts and class names metadata
COPY detect.py download_model_v2.py download_resnet.py ./
COPY ai_model/imagenet_classes.txt ./ai_model/imagenet_classes.txt

# Run Python scripts to download model binary files during build
RUN python download_model_v2.py && python download_resnet.py

# Create directory for uploads and grant permissions
RUN mkdir -p uploads && chmod 777 uploads

# Default environment variables (can be overridden at runtime)
ENV PYTHON_CMD=/opt/venv/bin/python
ENV DB_URL=jdbc:mysql://db:3306/ai_detection_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
ENV DB_USER=root
ENV DB_PASSWORD=Root

EXPOSE 8080

CMD ["catalina.sh", "run"]
