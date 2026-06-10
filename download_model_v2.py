# download_model_v2.py
import os
import urllib.request

MODEL_DIR = "ai_model"
PROTOTXT_URL = "https://raw.githubusercontent.com/chuanqi305/MobileNet-SSD/master/voc/MobileNetSSD_deploy.prototxt"
# Using raw link of PINTO0309's repo which github redirects to standard LFS binary download
CAFFEMODEL_URL = "https://raw.githubusercontent.com/PINTO0309/MobileNet-SSD-RealSense/master/caffemodel/MobileNetSSD/MobileNetSSD_deploy.caffemodel"

prototxt_path = os.path.join(MODEL_DIR, "MobileNetSSD_deploy.prototxt")
caffemodel_path = os.path.join(MODEL_DIR, "MobileNetSSD_deploy.caffemodel")

if not os.path.exists(MODEL_DIR):
    os.makedirs(MODEL_DIR)

def download_file(url, path):
    print(f"Downloading {url} to {path}...")
    try:
        # Some servers block Python default user agent
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            with open(path, 'wb') as f:
                f.write(response.read())
        print(f"Download successful. File size: {os.path.getsize(path)} bytes")
    except Exception as e:
        print(f"Error downloading {url}: {e}")

download_file(PROTOTXT_URL, prototxt_path)
download_file(CAFFEMODEL_URL, caffemodel_path)
print("Model check complete.")
