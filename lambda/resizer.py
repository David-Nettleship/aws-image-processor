from PIL import Image

def create_thumbnail(input_image_path, output_image_path, size=(128, 128)):
    """
    Create a thumbnail from an input image
    
    Args:
        input_image_path (str): Path to the input image
        output_image_path (str): Path where the thumbnail will be saved
        size (tuple): Desired thumbnail size in pixels (width, height)
    """
    try:
        # Open the image
        with Image.open(input_image_path) as img:
            # Create a thumbnail while maintaining aspect ratio
            img.thumbnail(size, Image.LANCZOS)
            
            # Save the thumbnail
            img.save(output_image_path)
            print(f"Thumbnail created successfully! Size: {img.size}")
            
    except Exception as e:
        print(f"An error occurred: {str(e)}")

# Example usage
if __name__ == "__main__":
    input_path = "pingu.jpg"  # Replace with your image path
    output_path = "thumbnail.jpg"      # Replace with desired output path
    thumbnail_size = (128, 128)        # Adjust size as needed
    
    create_thumbnail(input_path, output_path, thumbnail_size)
