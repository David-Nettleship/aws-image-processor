from PIL import Image
import os

def create_thumbnail(input_image_path, output_image_path, size=(128, 128)):
    try:
        with Image.open(input_image_path) as img:
            img.thumbnail(size, Image.LANCZOS)
            img.save(output_image_path)
            print(f"Thumbnail created successfully! Size: {img.size}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

def process_images():
    input_dir = "/app/input"
    output_dir = "/app/output"
    
    while True:
        for filename in os.listdir(input_dir):
            if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
                input_path = os.path.join(input_dir, filename)
                output_path = os.path.join(output_dir, f"thumb_{filename}")
                
                if not os.path.exists(output_path):
                    print(f"Processing {filename}")
                    create_thumbnail(input_path, output_path)

if __name__ == "__main__":
    process_images()
