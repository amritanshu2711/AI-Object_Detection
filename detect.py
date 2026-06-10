# detect.py
import sys
import os
import json
import cv2
import numpy as np

# PASCAL VOC classes for MobileNet-SSD
CLASSES = [
    "background", "aeroplane", "bicycle", "bird", "boat",
    "bottle", "bus", "car", "cat", "chair", "cow", "diningtable",
    "dog", "horse", "motorbike", "person", "pottedplant",
    "sheep", "sofa", "train", "tvmonitor"
]

# Map model class names to target database display names
CLASS_MAPPING = {
    "person": "Person",
    "car": "Car",
    "bicycle": "Bike",
    "motorbike": "Bike",
    "bottle": "Bottle",
    "chair": "Chair",
    "sofa": "Chair",
    "dog": "Animal",
    "cat": "Animal",
    "cow": "Animal",
    "horse": "Animal",
    "sheep": "Animal",
    "pottedplant": "Plant/Flower"
}

# Semantic Groups for constraint-based classification
ANIMAL_INDICES = set(range(0, 398)) # 0 to 397 (birds, mammals, reptiles, insects, etc.)

VEHICLE_INDICES = {
    404, 405, 406, 408, 467, 469, 511, 512, 555, 556, 566, 570, 574, 576, 
    587, 610, 628, 655, 657, 661, 666, 671, 672, 706, 718, 735, 752, 780, 
    803, 804, 815, 818, 821, 830, 834, 848, 865, 867, 868, 875, 896, 915
}

PLANT_FLOWER_INDICES = {
    985, 986, 987, 990, 992, 993, 994, 995, 996, 997, 998, 947, 937, 938, 
    939, 940, 941, 942, 943, 944, 945, 581, 742, 884
}

FURNITURE_INDICES = {
    424, 454, 496, 527, 533, 560, 565, 704, 766, 832, 895
}

def compute_iou(box1, box2):
    # box format: [x, y, w, h]
    x1 = max(box1[0], box2[0])
    y1 = max(box1[1], box2[1])
    x2 = min(box1[0] + box1[2], box2[0] + box2[2])
    y2 = min(box1[1] + box1[3], box2[1] + box2[3])
    
    intersection = max(0, x2 - x1) * max(0, y2 - y1)
    area1 = box1[2] * box1[3]
    area2 = box2[2] * box2[3]
    union = area1 + area2 - intersection
    
    if union == 0:
        return 0.0
    return intersection / union

def apply_nms(results, iou_threshold=0.5):
    # Sort results by confidence score descending
    sorted_results = sorted(results, key=lambda x: x["confidence_score"], reverse=True)
    keep = []
    
    for res in sorted_results:
        box = [res["box_x"], res["box_y"], res["box_width"], res["box_height"]]
        should_keep = True
        for kept_res in keep:
            kept_box = [kept_res["box_x"], kept_res["box_y"], kept_res["box_width"], kept_res["box_height"]]
            if compute_iou(box, kept_box) > iou_threshold:
                should_keep = False
                break
        if should_keep:
            keep.append(res)
            
    return keep

def classify_crop_constrained(crop, onnx_net, labels, allowed_indices=None):
    try:
        # Preprocess for MobileNetV2 ONNX (size=224x224, mean=[123.68, 116.78, 103.94], std=[0.229, 0.224, 0.225])
        mean = (123.68, 116.78, 103.94)
        blob = cv2.dnn.blobFromImage(crop, 1.0 / 255.0, (224, 224), mean, swapRB=True, crop=False)
        
        std = np.array([0.229, 0.224, 0.225], dtype=np.float32).reshape(1, 3, 1, 1)
        blob = blob / std
        
        onnx_net.setInput(blob)
        preds = onnx_net.forward()[0]
        
        # Softmax transformation
        exp_preds = np.exp(preds - np.max(preds))
        probs = exp_preds / np.sum(exp_preds)
        
        # Filter probabilities based on allowed indices
        if allowed_indices is not None:
            mask = np.zeros_like(probs)
            for idx in allowed_indices:
                if idx < len(mask):
                    mask[idx] = 1.0
            probs = probs * mask
            prob_sum = np.sum(probs)
            if prob_sum > 0:
                probs = probs / prob_sum
            else:
                return None, 0.0
                
        top_idx = np.argmax(probs)
        if probs[top_idx] > 0.0:
            return labels[top_idx], float(probs[top_idx])
        return None, 0.0
    except Exception:
        return None, 0.0

def main():
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Missing arguments. Usage: detect.py <image_path> <threshold>"}))
        sys.exit(1)

    image_path = sys.argv[1]
    try:
        threshold = float(sys.argv[2])
    except ValueError:
        threshold = 0.5

    if not os.path.exists(image_path):
        print(json.dumps({"error": f"Image file not found: {image_path}"}))
        sys.exit(1)

    # Paths to model files
    model_dir = "ai_model"
    prototxt = os.path.join(model_dir, "MobileNetSSD_deploy.prototxt")
    caffemodel = os.path.join(model_dir, "MobileNetSSD_deploy.caffemodel")

    if not os.path.exists(prototxt) or not os.path.exists(caffemodel):
        print(json.dumps({"error": "Model files missing. Run download_model_v2.py first."}))
        sys.exit(1)

    # Load the object detection model
    detector_net = cv2.dnn.readNetFromCaffe(prototxt, caffemodel)

    # Load ImageNet ONNX model for detailed classification
    onnx_path = os.path.join(model_dir, "mobilenetv2-12.onnx")
    labels_path = os.path.join(model_dir, "imagenet_classes.txt")
    
    onnx_net = None
    imagenet_labels = []
    if os.path.exists(onnx_path) and os.path.exists(labels_path):
        try:
            onnx_net = cv2.dnn.readNetFromONNX(onnx_path)
            with open(labels_path, "r") as f:
                imagenet_labels = [line.strip() for line in f.readlines()]
        except Exception as e:
            print(f"Error loading ONNX classifier: {e}", file=sys.stderr)

    # Load the image
    image = cv2.imread(image_path)
    if image is None:
        print(json.dumps({"error": f"Failed to load image: {image_path}"}))
        sys.exit(1)

    # Get dimensions
    (h_orig, w_orig) = image.shape[:2]

    # Preprocess image for MobileNetSSD
    blob = cv2.dnn.blobFromImage(cv2.resize(image, (300, 300)), 0.007843, (300, 300), 127.5)
    detector_net.setInput(blob)
    detections = detector_net.forward()

    results = []

    # Loop over detections
    for i in range(detections.shape[2]):
        confidence = detections[0, 0, i, 2]

        if confidence >= threshold:
            class_idx = int(detections[0, 0, i, 1])
            class_name = CLASSES[class_idx]
            
            # Skip background and person (people are generic)
            if class_name == "background" or class_name == "person":
                display_name = "Person" if class_name == "person" else class_name.title()
            else:
                display_name = CLASS_MAPPING.get(class_name, class_name.title())

            # Bounding box coordinates (normalized)
            xmin = max(0.0, min(1.0, detections[0, 0, i, 3]))
            ymin = max(0.0, min(1.0, detections[0, 0, i, 4]))
            xmax = max(0.0, min(1.0, detections[0, 0, i, 5]))
            ymax = max(0.0, min(1.0, detections[0, 0, i, 6]))

            # Map normalized coordinates back to standard 640x480 space
            x_640 = int(xmin * 640)
            y_480 = int(ymin * 480)
            w_640 = int((xmax - xmin) * 640)
            h_480 = int((ymax - ymin) * 480)

            # Extract crop for detailed classification
            x_start = int(xmin * w_orig)
            y_start = int(ymin * h_orig)
            x_end = int(xmax * w_orig)
            y_end = int(ymax * h_orig)

            if x_end > x_start and y_end > y_start and class_name != "person":
                crop = image[y_start:y_end, x_start:x_end]
                
                # Check for color-profile flowers first if it is a plant/flower
                if class_name == "pottedplant":
                    try:
                        hsv = cv2.cvtColor(crop, cv2.COLOR_BGR2HSV)
                        lower_red1 = np.array([0, 40, 40])
                        upper_red1 = np.array([10, 255, 255])
                        lower_red2 = np.array([170, 40, 40])
                        upper_red2 = np.array([180, 255, 255])
                        lower_pink = np.array([140, 40, 40])
                        upper_pink = np.array([170, 255, 255])
                        lower_yellow = np.array([15, 40, 40])
                        upper_yellow = np.array([35, 255, 255])
                        lower_purple = np.array([110, 40, 40])
                        upper_purple = np.array([140, 255, 255])
                        lower_white = np.array([0, 0, 170])
                        upper_white = np.array([180, 40, 255])

                        mask_red1 = cv2.inRange(hsv, lower_red1, upper_red1)
                        mask_red2 = cv2.inRange(hsv, lower_red2, upper_red2)
                        mask_red = cv2.bitwise_or(mask_red1, mask_red2)
                        mask_pink = cv2.inRange(hsv, lower_pink, upper_pink)
                        mask_yellow = cv2.inRange(hsv, lower_yellow, upper_yellow)
                        mask_purple = cv2.inRange(hsv, lower_purple, upper_purple)
                        mask_white = cv2.inRange(hsv, lower_white, upper_white)

                        total_px = crop.shape[0] * crop.shape[1]
                        red_pink_ratio = (cv2.countNonZero(mask_red) + cv2.countNonZero(mask_pink)) / total_px
                        yellow_ratio = cv2.countNonZero(mask_yellow) / total_px
                        purple_ratio = cv2.countNonZero(mask_purple) / total_px
                        white_ratio = cv2.countNonZero(mask_white) / total_px

                        if red_pink_ratio > 0.12:
                            display_name = "Rose Flower (Rose)"
                        elif yellow_ratio > 0.12:
                            display_name = "Sunflower / Marigold"
                        elif white_ratio > 0.15:
                            display_name = "Daisy Flower (Daisy)"
                        elif purple_ratio > 0.12:
                            display_name = "Orchid / Lavender"
                        else:
                            # Fallback to ImageNet classifier constrained to plant/flower classes
                            if onnx_net is not None:
                                detail_class, detail_prob = classify_crop_constrained(crop, onnx_net, imagenet_labels, PLANT_FLOWER_INDICES)
                                if detail_class and detail_prob >= 0.15:
                                    display_name = detail_class.title()
                    except Exception:
                        pass
                else:
                    # For other classes (e.g. dog, cat, car, chair, bottle), refine using ImageNet classifier with semantic constraints
                    if onnx_net is not None:
                        allowed = None
                        if class_name in ["dog", "cat", "cow", "horse", "sheep", "bird"]:
                            allowed = ANIMAL_INDICES
                        elif class_name in ["car", "bus", "train", "aeroplane", "boat", "bicycle", "motorbike"]:
                            allowed = VEHICLE_INDICES
                        elif class_name in ["chair", "sofa", "diningtable"]:
                            allowed = FURNITURE_INDICES
                            
                        detail_class, detail_prob = classify_crop_constrained(crop, onnx_net, imagenet_labels, allowed)
                        if detail_class and detail_prob >= 0.15:
                            display_name = detail_class.title()

            # Ensure bounding boxes are positive and within boundaries
            if w_640 > 0 and h_480 > 0:
                results.append({
                    "object_name": display_name,
                    "confidence_score": float(confidence),
                    "box_x": x_640,
                    "box_y": y_480,
                    "box_width": w_640,
                    "box_height": h_480
                })

    # Apply Non-Maximum Suppression (NMS) to eliminate redundant overlapping bounding boxes
    results = apply_nms(results, iou_threshold=0.5)

    # If no objects are detected by the detector, run classification on the entire image
    if not results and onnx_net is not None:
        detail_class, detail_prob = classify_crop_constrained(image, onnx_net, imagenet_labels, None)
        if detail_class and detail_prob >= 0.15:
            results.append({
                "object_name": detail_class.title(),
                "confidence_score": float(detail_prob),
                "box_x": 0,
                "box_y": 0,
                "box_width": 640,
                "box_height": 480
            })

    print(json.dumps(results))

if __name__ == "__main__":
    main()
