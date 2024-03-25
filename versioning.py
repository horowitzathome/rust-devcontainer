import sys

def calculate_tag(version, latest_tag):
    if latest_tag:
        tag_parts = latest_tag.split('-')
        if len(tag_parts) == 2 and tag_parts[0] == version:
            return f"{version}-{int(tag_parts[1]) + 1}"
        else:
            return f"{version}-1"
    else:
        return f"{version}-1"

if __name__ == "__main__":
    version = sys.argv[1]
    latest_tag = sys.argv[2]
    new_tag = calculate_tag(version, latest_tag)
    print(new_tag)
