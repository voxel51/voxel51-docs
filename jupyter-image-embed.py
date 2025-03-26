import os
from pathlib import Path
import base64
import nbformat

JUPYTER_DIRS = ["./docs/tutorials", "./docs/how_do_i/recipes"]

def get_webp_base64(file_path: str | Path) -> str:
    """
    Reads a WebP file and returns its base64 encoding with data URL prefix.

    Args:
        file_path: Path to the WebP file

    Returns:
        str: Base64 encoded string with data URL prefix
    """
    image_data = Path(file_path).read_bytes()
    base64_str = base64.b64encode(image_data).decode('utf-8')
    return f"data:image/webp;base64,{base64_str}"


def update_notebook_images(notebook_path: str, output_path: str) -> None:
    """
    Updates a Jupyter notebook by replacing relative image paths with base64 encoded data.

    Args:
        notebook_path: Path to the input notebook
        output_path: Path where to save the modified notebook
    """
    notebook_dir = Path(notebook_path).parent
    images_dir = notebook_dir / 'images'

    # Read the notebook
    with open(notebook_path, 'r', encoding='utf-8') as f:
        notebook = nbformat.read(f, as_version=4)

    # Iterate through cells
    for cell in notebook.cells:
        if cell.cell_type == "markdown":
            # Find all image references in markdown
            lines = cell.source.split('\n')
            updated_lines = []

            for line in lines:
                if '![' in line and './images/' in line:
                    # Extract image path using basic string operations
                    start = line.find('./images/')
                    end = line.find(')', start)
                    if end == -1:  # If no closing parenthesis, try closing bracket
                        end = line.find(']', start)
                    if end != -1:
                        relative_path = line[start:end]
                        image_path = notebook_dir / relative_path
                        if image_path.exists() and image_path.suffix == '.webp':
                            base64_image = get_webp_base64(image_path)
                            line = line.replace(relative_path, base64_image)
                updated_lines.append(line)

            cell.source = '\n'.join(updated_lines)

    # Save the modified notebook
    with open(output_path, 'w', encoding='utf-8') as f:
        nbformat.write(notebook, f)


# Example usage
if __name__ == "__main__":
    for dir in JUPYTER_DIRS:
        directory = Path(dir)
        notebook_files = list(directory.glob('*.ipynb'))
        for notebook_file in notebook_files:
            update_notebook_images(
                notebook_path=notebook_file,
                output_path=notebook_file
            )
