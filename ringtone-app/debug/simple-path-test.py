# Rules applied
import os

print("Testing paths...")
print(f"Current directory: {os.getcwd()}")

# Test the path calculation
backend_dir = os.path.dirname(os.path.dirname(__file__))
print(f"Backend directory: {backend_dir}")

ringtones_path = os.path.join(backend_dir, 'ringtones')
print(f"Ringtones path: {ringtones_path}")
print(f"Ringtones path exists: {os.path.exists(ringtones_path)}")

# Show absolute path
abs_path = os.path.abspath(ringtones_path)
print(f"Absolute ringtones path: {abs_path}")

# List parent directory contents
parent_dir = os.path.dirname(backend_dir)
print(f"Parent directory: {parent_dir}")
if os.path.exists(parent_dir):
    contents = os.listdir(parent_dir)
    print(f"Parent directory contents: {contents}")
