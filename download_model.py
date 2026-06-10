# download_model.py
import os
import urllib.request

MODEL_DIR = "ai_model"
PROTOTXT_URL = "https://raw.githubusercontent.com/chuanqi305/MobileNet-SSD/master/MobileNetSSD_deploy.prototxt"
CAFFEMODEL_URL = "https://raw.githubusercontent.com/chuanqi305/MobileNet-SSD/master/MobileNetSSD_deploy.caffemodel"

prototxt_path = os.path.join(MODEL_DIR, "MobileNetSSD_deploy.prototxt")
caffemodel_path = os.path.join(MODEL_DIR, "MobileNetSSD_deploy.caffemodel")

if not os.path.exists(MODEL_DIR):
    os.makedirs(MODEL_DIR)

def download_file(url, path):
    if not os.path.exists(path):
        print(f"Downloading {url} to {path}...")
        try:
            urllib.request.urlretrieve(url, path)
            print("Download completed successfully.")
        except Exception as e:
            print(f"Error downloading {url}: {e}")
            # Try fallback URL if needed
    else:
        print(f"{path} already exists.")

download_file(PROTOTXT_URL, prototxt_path)
download_file(CAFFEMODEL_URL, caffemodel_path)
print("Model check complete.")
