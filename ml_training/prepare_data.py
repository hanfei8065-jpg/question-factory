import os
import json
import cv2
import numpy as np
from PIL import Image

def prepare_image(image_path):
    """预处理图像"""
    img = Image.open(image_path)
    
    # 转换为RGB格式
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # 调整大小为训练尺寸
    img = img.resize((640, 640))
    
    # 转换为numpy数组
    img_array = np.array(img)
    
    # 标准化
    img_array = img_array.astype(np.float32) / 255.0
    
    return img_array

def annotate_questions(image_path, output_file):
    """交互式标注工具"""
    img = cv2.imread(image_path)
    boxes = []
    
    def mouse_callback(event, x, y, flags, param):
        nonlocal boxes
        if event == cv2.EVENT_LBUTTONDOWN:
            # 开始框选
            param['drawing'] = True
            param['start'] = (x, y)
        elif event == cv2.EVENT_MOUSEMOVE and flags == cv2.EVENT_FLAG_LBUTTON:
            # 绘制实时框
            if param['drawing']:
                img_copy = img.copy()
                cv2.rectangle(img_copy, param['start'], (x, y), (0, 255, 0), 2)
                cv2.imshow('Annotate', img_copy)
        elif event == cv2.EVENT_LBUTTONUP:
            # 完成框选
            param['drawing'] = False
            boxes.append([
                min(param['start'][0], x) / img.shape[1],  # 归一化坐标
                min(param['start'][1], y) / img.shape[0],
                max(param['start'][0], x) / img.shape[1],
                max(param['start'][1], y) / img.shape[0],
                1.0  # 置信度
            ])
            # 绘制确认框
            cv2.rectangle(img, param['start'], (x, y), (0, 255, 0), 2)
            cv2.imshow('Annotate', img)
    
    # 设置窗口和回调
    cv2.namedWindow('Annotate')
    param = {'drawing': False, 'start': None}
    cv2.setMouseCallback('Annotate', mouse_callback, param)
    
    cv2.imshow('Annotate', img)
    while True:
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):  # 按q退出
            break
        elif key == ord('c'):  # 按c清除最后一个框
            if boxes:
                boxes.pop()
                img_copy = img.copy()
                for box in boxes:
                    pt1 = (int(box[0] * img.shape[1]), int(box[1] * img.shape[0]))
                    pt2 = (int(box[2] * img.shape[1]), int(box[3] * img.shape[0]))
                    cv2.rectangle(img_copy, pt1, pt2, (0, 255, 0), 2)
                cv2.imshow('Annotate', img_copy)
    
    cv2.destroyAllWindows()
    
    # 保存标注
    annotation = {
        'image': os.path.basename(image_path),
        'boxes': boxes
    }
    
    with open(output_file, 'w') as f:
        json.dump(annotation, f, indent=2)

def main():
    # 创建数据目录
    os.makedirs('data/images', exist_ok=True)
    os.makedirs('data/annotations', exist_ok=True)
    
    # 标注所有图片
    image_dir = 'data/images'
    for img_file in os.listdir(image_dir):
        if img_file.endswith(('.jpg', '.png', '.jpeg')):
            image_path = os.path.join(image_dir, img_file)
            output_file = os.path.join('data/annotations', 
                                     f'{os.path.splitext(img_file)[0]}.json')
            print(f'标注图片: {img_file}')
            annotate_questions(image_path, output_file)

if __name__ == '__main__':
    main()