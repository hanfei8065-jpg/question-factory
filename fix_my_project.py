import os
import re

def recover():
    manifest_name = 'learnist_manifest.txt' # 确保文件名一致
    if not os.path.exists(manifest_name):
        print("错误：未在根目录找到 learnist_manifest.txt")
        return

    with open(manifest_name, 'r', encoding='utf-8') as f:
        content = f.read()

    # 匹配你给我的那个“带分类标签”的指令头
    pattern = r"// ##########################################\s+// # FILE: (.*?)\s+// ##########################################"
    
    parts = re.split(pattern, content)
    
    for i in range(1, len(parts), 2):
        file_path = parts[i].strip()
        file_body = parts[i+1].strip()
        
        dir_name = os.path.dirname(file_path)
        if dir_name and not os.path.exists(dir_name):
            os.makedirs(dir_name)
            
        # 'w' 模式会自动清空原文件内容再写入
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(file_body)
        print(f"💎 原始定稿已覆盖还原: {file_path}")

if __name__ == "__main__":
    recover()