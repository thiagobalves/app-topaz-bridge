import json
import os

import requests

if __name__ == '__main__':
    with open(".version", 'r') as version_file:
        with open('.react-native-version', 'r') as react_native_version:
            reactNativeVersion = react_native_version.read().strip()
        react_native_version.close()

        version = version_file.read().strip()
        buildNumber = os.environ.get("CI_PIPELINE_ID")
        platform = 'react-native'
        username = os.environ['JIRA_USER']
        password = os.environ['JIRA_PASSWORD']
        baseUrl = os.environ['CONFLUENCE_BASE_URL']
        spaceKey = 'PHB'
        mobDevToolsArtifactBaseUrl = os.environ['ARTIFACT_BASE_URL']

        pageInfoResponse = requests.get(
            baseUrl + '?title=' + version + '+(' + platform + ')&spaceKey=' + spaceKey + '&expand=body.storage',
            auth=(username, password),
            verify=False
        )

        pageJson = pageInfoResponse.json()


        pageId = pageJson['results'][0]['id']
        pageTitle = pageJson['results'][0]['title']
        pageHtml = pageJson['results'][0]['body']['storage']['value']

        pageVersionResponse = requests.get(
            baseUrl + '?title=' + version + '+(' + platform + ')&spaceKey=' + spaceKey + '&expand=version',
            auth=(username, password),
            verify=False
        )
        pageVersion = pageVersionResponse.json()['results'][0]['version']['number']

        pageHtml = pageHtml.replace('##package##',
                                    '<p><a href="' + mobDevToolsArtifactBaseUrl + '?version=' + version + '.' + buildNumber + '&amp;os=' + platform + '">Download React-Native Heartbeat</a></p>')

        pageHtml = pageHtml.replace('##react-native-dependency##', '<p>' + reactNativeVersion + '</p>')

        headers = {'content-type': 'application/json'}
        data = {
            'id': pageId,
            'type': 'page',
            'title': pageTitle,
            'space': {'key': spaceKey},
            'body': {'storage': {'value': pageHtml, 'representation': 'storage'}},
            'version': {'number': pageVersion + 1}
        }
        pageUpdateResponse = requests.put(
            baseUrl + '/' + pageId,
            auth=(username, password),
            headers=headers,
            data=json.dumps(data),
            verify=False
        )
