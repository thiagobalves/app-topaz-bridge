import os


def validate_version():
    with open('.version', 'r') as version_file:
        version = version_file.read().strip()
    version_file.close()
    branch_version = os.environ.get('CI_COMMIT_REF_NAME').replace("rb_", "").replace("_", ".")
    assert version == branch_version, f"Version of .version file and branch name does not match. Branch version {branch_version} and .version file {version}"
    print("Valid version")


if __name__ == '__main__':
    validate_version()
