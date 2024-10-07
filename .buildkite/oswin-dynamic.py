import yaml
import json
# from jinja2 import Template


class LiteralString(str):
    pass


class QuotedString(str):
    pass


def literal_string_representer(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')


def quoted_string_representer(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')


yaml.add_representer(LiteralString, literal_string_representer)
yaml.add_representer(QuotedString, quoted_string_representer)


def load_json_variables(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)


def format_commands(commands):
    return LiteralString('\n'.join(commands) + '\n')


def format_plugins(plugins):
    return [
         {k: QuotedString(v) if isinstance(v, str) else v for k, v in plugin.items()}
#        {QuotedString(v) if isinstance(v, str) else v for k, v in plugin.items()}
        for plugin in plugins
    ]


def generate_yaml_data(items):
    people = []
    for item in items:
        person = {
            'label': QuotedString(item['label']),
            'key': QuotedString(item['key']),
            'commands': format_commands(item['commands']),
            'plugins': format_plugins(item['plugins'])
        }
        people.append(person)
    return {'people': people}


def save_yaml(data, file_path):
    with open(file_path, 'w') as file:
        yaml.dump(data, file, default_flow_style=False, sort_keys=False)


def main():
    variables_path = 'variables.json'
    output_path = 'pipeline.yml'

    items = load_json_variables(variables_path)
    yaml_data = generate_yaml_data(items)
    save_yaml(yaml_data, output_path)

    print(f"YAML file generated and saved to {output_path}")


if __name__ == "__main__":
    main()
