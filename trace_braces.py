content = open('d:/alchemist-final/lib/daily_task_form_sheet.dart').read()
level = 0
for i, line in enumerate(content.split('\n')):
    delta = line.count('{') - line.count('}')
    old_level = level
    level += delta
    if old_level == 1 and level == 0:
        print(f"Class or method closed at line {i+1}: {line.strip()}")
    if level < 0:
        print(f"Negative level at line {i+1}: {line.strip()}")
        level = 0
