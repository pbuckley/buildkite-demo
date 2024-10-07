from ruamel.yaml import YAML
import json

yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.preserve_quotes = True


def load_json_variables(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)


def format_commands(commands):
    return '\n'.join(commands) + '\n'  # Add an extra newline


def format_plugins(plugins):
    formatted_plugins = []
    for plugin in plugins:
        name = list(plugin.keys())[0]
        properties = plugin[name]
        formatted_plugin = {name: {
            k: v for k, v in properties.items()
        }}
        formatted_plugins.append(formatted_plugin)
    return formatted_plugins


def generate_yaml_data(items):
    people = []
    for item in items:
        person = {
            'label': item['label'],
            'key': item['key'],
            'commands': format_commands(item['commands']),
            'plugins': format_plugins(item['plugins'])
        }
        people.append(person)
    return {'people': people}


def save_yaml(data, file_path):
    with open(file_path, 'w') as file:
        yaml.dump(data, file)


def main():
    variables_path = 'variables.json'
    output_path = 'pipeline.yml'

    items = load_json_variables(variables_path)
    yaml_data = generate_yaml_data(items)
    save_yaml(yaml_data, output_path)

    print(f"YAML file generated and saved to {output_path}")


if __name__ == "__main__":
    main()
