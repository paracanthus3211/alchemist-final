content = open('d:/alchemist-final/lib/daily_task_form_sheet.dart').read()
stack = []
lines = content.split('\n')
for i, line in enumerate(lines):
    for char in line:
        if char == '{':
            stack.append(i + 1)
        elif char == '}':
            if not stack:
                print(f"Extra }} at line {i + 1}")
            else:
                stack.pop()

if stack:
    for line_num in stack:
        print(f"Unclosed {{ from line {line_num}")
