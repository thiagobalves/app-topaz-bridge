import os
import re
import shutil
from argparse import ArgumentParser
from shutil import rmtree
from subprocess import Popen, PIPE

from upload_to_s3 import upload_file_to_s3

ZIP_NAME = ''


def build(build_dir, build_version, react_native_version):
    if os.path.exists(build_dir):
        rmtree(build_dir)

    os.mkdir(build_dir)

    git_cmd = ['git', 'archive', '--format', 'tar', 'HEAD']
    git = Popen(git_cmd, stdout=PIPE)

    tar_cmd = ['tar', '-C', args.build_dir, '--exclude-from', '.tarignore', '-xf', '-']
    tar = Popen(tar_cmd, stdin=git.stdout)

    tar.wait()
    git.wait()

    podspec = update_build_version('Scripts/template/RNHeartbeat.podspec.template', build_version)
    with open('build/RNHeartbeat.podspec', 'w') as file:
        file.write(podspec)

    package_json = update_build_version('Scripts/template/package.json.template', build_version, react_native_version)
    with open('build/package.json', 'w') as file:
        file.write(package_json)


def update_build_version(path, build_version, react_native_version=None):
    with open(path, 'r') as file:
        template = file.read()
    assert template, 'Erro ao ler o template'
    if react_native_version:
        return template.format(build_version=build_version, react_native_version=react_native_version)
    return template.format(build_version=build_version)


def zip_build_folder(build_version):
    global ZIP_NAME
    ZIP_NAME = 'react-native-heartbeat-' + build_version
    shutil.make_archive(ZIP_NAME, 'zip', 'build')


def main(build_dir, build_version, react_native_version):
    build(build_dir, build_version, react_native_version)
    zip_build_folder(build_version)
    upload_file_to_s3(ZIP_NAME)


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--build-version', help='Use version instead of .version file')
    parser.add_argument('--react-native-version', help='Use react native version instead of .react-native-version file')
    parser.add_argument('--build-dir', default='build', help='Build directory')
    args = parser.parse_args()

    if not args.build_version:
        with open('.version', 'r') as version_file:
            version = version_file.read().strip()
            assert re.match(r'^(\d+\.){2}\d+$', version), 'Error: version does not match pattern x.y.z'
        args.build_version = '.'.join([version, os.environ.get('CI_PIPELINE_ID')])
        version_file.close()
    if not args.react_native_version:
        with open('.react-native-version', 'r') as react_native_version_file:
            rn_version = react_native_version_file.read().strip()
        args.react_native_version = rn_version
        react_native_version_file.close()
    main(args.build_dir, args.build_version, args.react_native_version)
