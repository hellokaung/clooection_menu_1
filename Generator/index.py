import json

def extract_descriptions(input_path, output_path):
    try:
        # Read the input JSON file
        with open(input_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
        
        # Extract description[0] from each item in lists
        descriptions = [item['description'][0] for item in data['lists']]
        
        # Save the descriptions to a new JSON file
        with open(output_path, 'w', encoding='utf-8') as file:
            json.dump(descriptions, file, indent=4, ensure_ascii=False)
        
        print(f"Successfully extracted descriptions and saved to {output_path}")
        
    except FileNotFoundError:
        print(f"Error: Input file {input_path} not found")
    except KeyError as e:
        print(f"Error: Missing key {e} in JSON structure")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


input_file = "/home/cowboy/Development/project/collection_menu_1/Generator/menu.json"
output_file = "/home/cowboy/Development/project/collection_menu_1/Generator/descriptions_0.json"

extract_descriptions(input_file, output_file)