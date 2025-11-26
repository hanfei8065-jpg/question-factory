import os
import json
import cv2
import numpy as np
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow.keras import layers, Model

class QuestionDetectionModel:
    def __init__(self, input_shape=(640, 640, 3)):
        self.input_shape = input_shape
        self.model = self._build_model()

    def _build_model(self):
        # 基础模型 - 使用 EfficientNetB0 作为特征提取器
        base_model = tf.keras.applications.EfficientNetB0(
            include_top=False,
            weights='imagenet',
            input_shape=self.input_shape
        )
        
        # 冻结基础模型
        base_model.trainable = False
        
        # 构建检测头
        inputs = layers.Input(shape=self.input_shape)
        x = base_model(inputs)
        
        # 特征金字塔网络 (FPN)
        fpn_features = self._build_fpn(x)
        
        # 检测头
        detection_head = self._build_detection_head(fpn_features)
        
        # 输出层 - 预测边界框坐标 (x1, y1, x2, y2) 和置信度
        outputs = layers.Dense(5, activation='sigmoid', name='output')(detection_head)
        
        return Model(inputs=inputs, outputs=outputs)

    def _build_fpn(self, x):
        # 特征金字塔网络实现
        p5 = layers.Conv2D(256, 1, activation='relu')(x)
        p4 = layers.Conv2D(256, 1, activation='relu')(
            layers.UpSampling2D()(p5)
        )
        p3 = layers.Conv2D(256, 1, activation='relu')(
            layers.UpSampling2D()(p4)
        )
        
        return [p3, p4, p5]

    def _build_detection_head(self, features):
        # 合并多尺度特征
        merged = layers.Concatenate()(features)
        
        # 检测头网络
        x = layers.Conv2D(256, 3, padding='same', activation='relu')(merged)
        x = layers.BatchNormalization()(x)
        x = layers.Conv2D(128, 3, padding='same', activation='relu')(x)
        x = layers.BatchNormalization()(x)
        x = layers.GlobalAveragePooling2D()(x)
        x = layers.Dense(512, activation='relu')(x)
        x = layers.Dropout(0.5)(x)
        
        return x

    def compile_model(self):
        self.model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
            loss={
                'output': self._detection_loss
            },
            metrics=['accuracy']
        )

    def _detection_loss(self, y_true, y_pred):
        # 自定义损失函数
        # 边界框回归损失
        box_loss = tf.keras.losses.MSE(y_true[:, :4], y_pred[:, :4])
        
        # 置信度损失
        conf_loss = tf.keras.losses.BinaryCrossentropy()(
            y_true[:, 4:], y_pred[:, 4:]
        )
        
        return box_loss + conf_loss

    def train(self, train_data, val_data, epochs=50):
        return self.model.fit(
            train_data,
            validation_data=val_data,
            epochs=epochs,
            callbacks=[
                tf.keras.callbacks.EarlyStopping(
                    patience=5,
                    restore_best_weights=True
                ),
                tf.keras.callbacks.ReduceLROnPlateau(
                    factor=0.5,
                    patience=3
                )
            ]
        )

    def export_tflite(self, output_path):
        # 转换为 TFLite 模型
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
        
        # 保存模型
        with open(output_path, 'wb') as f:
            f.write(tflite_model)

def prepare_dataset(data_dir, annotation_file):
    """准备训练数据"""
    with open(annotation_file, 'r') as f:
        annotations = json.load(f)
    
    images = []
    labels = []
    
    for item in annotations:
        # 读取图片
        img_path = os.path.join(data_dir, item['image'])
        img = cv2.imread(img_path)
        img = cv2.resize(img, (640, 640))
        img = img / 255.0  # 归一化
        
        # 准备标签
        boxes = np.array(item['boxes'])  # [x1, y1, x2, y2, conf]
        
        images.append(img)
        labels.append(boxes)
    
    return np.array(images), np.array(labels)

def main():
    # 准备数据
    data_dir = 'data/images'
    annotation_file = 'data/annotations.json'
    
    X, y = prepare_dataset(data_dir, annotation_file)
    X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=0.2)
    
    # 创建数据集
    train_dataset = tf.data.Dataset.from_tensor_slices((X_train, y_train))
    val_dataset = tf.data.Dataset.from_tensor_slices((X_val, y_val))
    
    # 批处理
    BATCH_SIZE = 16
    train_dataset = train_dataset.batch(BATCH_SIZE)
    val_dataset = val_dataset.batch(BATCH_SIZE)
    
    # 创建和训练模型
    model = QuestionDetectionModel()
    model.compile_model()
    history = model.train(train_dataset, val_dataset)
    
    # 导出模型
    model.export_tflite('assets/models/question_detector.tflite')

if __name__ == '__main__':
    main()