import sys


def main(input_path, postfix='.sh'):
    with open(input_path, 'r') as file_handle:
        lines = file_handle.readlines()
        envs = {}
        for line in lines:
            try:
                parts = line.split('=')
                name = parts[0]
                value = ''.join(parts[1:]).rstrip('\n')
            except ValueError:
                pass
            else:
                envs[name] = value

    output_path = f'{input_path}{postfix}'
    with open(output_path, 'w') as file_handle:
        lines = []
        for name, value in envs.items():
            line = f'{name}=\'{value}\'\n'
            lines.append(line)
        file_handle.writelines(lines)


if __name__ == '__main__':
    # Passes first argument as input path.
    main(sys.argv[1])
