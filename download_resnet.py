# download_resnet.py
import urllib.request
import os

def main():
    model_dir = "ai_model"
    if not os.path.exists(model_dir):
        os.makedirs(model_dir)

    model_url = "https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet50-v2-7.onnx"
    model_path = os.path.join(model_dir, "resnet50-v2-7.onnx")

    print(f"Downloading ResNet50-v2 ONNX model (approx. 102MB) from: {model_url}")
    print("This might take a minute depending on your internet connection...")
    try:
        urllib.request.urlretrieve(model_url, model_path)
        print("ResNet50 model downloaded successfully.")
    except Exception as e:
        print(f"Error downloading model: {e}")

if __name__ == "__main__":
    main()
