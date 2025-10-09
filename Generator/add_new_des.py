import json

def update_descriptions(input_menu_path, input_desc_path, output_menu_path, index):
    try:
        # Read the menu JSON file
        with open(input_menu_path, 'r', encoding='utf-8') as file:
            menu_data = json.load(file)
        
        # Read the descriptions JSON file
        with open(input_desc_path, 'r', encoding='utf-8') as file:
            descriptions = json.load(file)
        
        # Ensure the number of descriptions matches the number of lists
        if len(descriptions) != len(menu_data['lists']):
            print(f"Error: Number of descriptions ({len(descriptions)}) does not match number of lists ({len(menu_data['lists'])})")
            return
        
        # Update descriptions at the specified index
        for i, item in enumerate(menu_data['lists']):
            # Ensure description is a list; if not, initialize it
            if not isinstance(item.get('description'), list):
                item['description'] = []
            
            # Extend the description list with None if index is beyond current length
            while len(item['description']) <= index:
                item['description'].append(None)
            
            # Insert or replace the description at the specified index
            item['description'][index] = descriptions[i]
        
        # Save the updated menu JSON
        with open(output_menu_path, 'w', encoding='utf-8') as file:
            json.dump(menu_data, file, indent=4, ensure_ascii=False)
        
        print(f"Successfully updated descriptions at index {index} in {output_menu_path}")
        
    except FileNotFoundError as e:
        print(f"Error: File not found - {e}")
    except KeyError as e:
        print(f"Error: Missing key {e} in JSON structure")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

# Example usage
if __name__ == "__main__":
    input_menu_file = "/home/cowboy/Development/project/collection_menu_1/Generator/menu.json"
    input_desc_file = "/home/cowboy/Development/project/collection_menu_1/Generator/descriptions_8.json"
    output_menu_file = "/home/cowboy/Development/project/collection_menu_1/Generator/menu_8.json"

    # Prompt user for index in the terminal
    while True:
        try:
            index = input("Enter the index where descriptions should be inserted (non-negative integer): ")
            index = int(index)
            if index < 0:
                print("Error: Index must be a non-negative integer")
                continue
            break
        except ValueError:
            print("Error: Index must be a valid integer")
    
    update_descriptions(input_menu_file, input_desc_file, output_menu_file, index)